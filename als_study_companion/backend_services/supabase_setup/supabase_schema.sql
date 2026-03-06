-- Supabase schema for ALS Study Companion
-- Create core tables: users, lessons, quizzes, questions, progress, announcements, centers
-- Note: this SQL assumes Supabase Auth is enabled and `auth.users` is populated.

create extension if not exists pgcrypto;

-- Users (profile data, separate from auth.users)
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  role text default 'student', -- 'student' | 'teacher' | 'admin'
  profile_image text,
  meta jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Lessons
create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  summary text,
  content jsonb,
  teacher_id uuid references public.users(id) on delete set null,
  published boolean default false,
  metadata jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Quizzes
create table if not exists public.quizzes (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid references public.lessons(id) on delete cascade,
  title text,
  metadata jsonb,
  created_at timestamptz default now()
);

-- Questions
create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid references public.quizzes(id) on delete cascade,
  question jsonb not null,
  created_at timestamptz default now()
);

-- Student progress (syncable)
create table if not exists public.progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete cascade,
  lesson_id uuid references public.lessons(id) on delete cascade,
  progress jsonb,
  synced boolean default false,
  updated_at timestamptz default now()
);

-- Announcements
create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text,
  target jsonb, -- e.g. {"roles": ["teacher","student"], "center_ids": [...]}
  created_by uuid references public.users(id),
  created_at timestamptz default now()
);

-- ALS Centers
create table if not exists public.centers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  contact jsonb,
  metadata jsonb,
  created_at timestamptz default now()
);

-- Indexes
create index if not exists idx_lessons_teacher on public.lessons(teacher_id);
create index if not exists idx_progress_user on public.progress(user_id);

-- Enable RLS for sensitive tables
alter table public.users enable row level security;
alter table public.lessons enable row level security;
alter table public.quizzes enable row level security;
alter table public.questions enable row level security;
alter table public.progress enable row level security;
alter table public.announcements enable row level security;
alter table public.centers enable row level security;

-- Policies
-- Helper: allow admins (JWT claim `role` == 'admin')

-- Users: allow users to read/update their own profile and admins to manage all
create policy users_select_self_or_admin on public.users for select using (
  (id::text = auth.uid()) OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);
create policy users_update_self on public.users for update using (
  (id::text = auth.uid()) OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);
create policy users_insert_admin_only on public.users for insert with check (
  (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);

-- Lessons: published are public; teachers can manage their lessons; admins can manage all
create policy lessons_select_published_or_owner_or_admin on public.lessons for select using (
  (published = true) OR (teacher_id::text = auth.uid()) OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);
create policy lessons_insert_teacher_or_admin on public.lessons for insert with check (
  (teacher_id::text = auth.uid()) OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);
create policy lessons_update_owner_or_admin on public.lessons for update using (
  (teacher_id::text = auth.uid()) OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);
create policy lessons_delete_owner_or_admin on public.lessons for delete using (
  (teacher_id::text = auth.uid()) OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);

-- Quizzes & Questions: follow lesson ownership
create policy quizzes_select_for_lesson_access on public.quizzes for select using (
  (exists(select 1 from public.lessons l where l.id = lesson_id and (l.published = true or l.teacher_id::text = auth.uid())))
  OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);
create policy quizzes_modify_owner_or_admin on public.quizzes for all using (
  (exists(select 1 from public.lessons l where l.id = lesson_id and l.teacher_id::text = auth.uid()))
  OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);
create policy questions_follow_quiz on public.questions for all using (
  (exists(select 1 from public.quizzes q join public.lessons l on q.lesson_id = l.id where q.id = quiz_id and l.teacher_id::text = auth.uid()))
  OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);

-- Progress: users can manage their own progress; teachers can read progress for their lessons; admins can manage all
create policy progress_select_owner_or_teacher_or_admin on public.progress for select using (
  (user_id::text = auth.uid())
  OR (exists(select 1 from public.lessons l where l.id = public.progress.lesson_id and l.teacher_id::text = auth.uid()))
  OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);
create policy progress_insert_owner on public.progress for insert with check (
  (user_id::text = auth.uid()) OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);
create policy progress_update_owner on public.progress for update using (
  (user_id::text = auth.uid()) OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);

-- Announcements: creators and admins manage announcements; select depends on target filtering (clients may filter client-side)
create policy announcements_select_public_or_admin on public.announcements for select using (
  (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
  OR true -- allow read for all authenticated users; apply filtering client-side if needed
);
create policy announcements_insert_creator_or_admin on public.announcements for insert with check (
  (created_by::text = auth.uid()) OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);

-- Centers: admins manage; read allowed for authenticated users
create policy centers_select_authenticated on public.centers for select using (
  (auth.role() = 'authenticated') OR (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);
create policy centers_modify_admin_only on public.centers for insert, update, delete with check (
  (current_setting('request.jwt.claims', true) ->> 'role' = 'admin')
);

-- End of schema
