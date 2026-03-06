-- Migration: email_verified, teacher_verified, audit_logs, lessons table, 
-- progress table, quizzes table, questions table, sessions table, 
-- announcements table, downloads table, RLS policies.

-- =============================================
-- 1. ADD EMAIL/TEACHER VERIFICATION COLUMNS
-- =============================================

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS email_verified    BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS teacher_verified  BOOLEAN DEFAULT false;

-- =============================================
-- 2. CREATE AUDIT LOGS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS public.audit_logs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id    TEXT NOT NULL,
  action      TEXT NOT NULL,
  target_id   TEXT,
  details     TEXT,
  created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Only admins can read audit logs
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'audit_logs_admin_select') THEN
    EXECUTE '
      CREATE POLICY audit_logs_admin_select ON public.audit_logs FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role = ''admin''
        )
      )';
  END IF;
END$$;

-- Only admins can insert audit logs
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'audit_logs_admin_insert') THEN
    EXECUTE '
      CREATE POLICY audit_logs_admin_insert ON public.audit_logs FOR INSERT
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role = ''admin''
        )
      )';
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_audit_logs_admin ON public.audit_logs (admin_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON public.audit_logs (created_at DESC);

-- =============================================
-- 3. CREATE LESSONS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS public.lessons (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title             TEXT NOT NULL,
  description       TEXT NOT NULL DEFAULT '',
  subject           TEXT NOT NULL,
  grade_level       TEXT NOT NULL,
  video_url         TEXT,
  study_guide_url   TEXT,
  thumbnail_url     TEXT,
  teacher_id        TEXT NOT NULL,
  duration_minutes  INTEGER DEFAULT 0,
  order_index       INTEGER DEFAULT 0,
  sync_status       TEXT DEFAULT 'synced',
  is_published      BOOLEAN DEFAULT false,
  created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;

-- Teachers can CRUD their own lessons
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'lessons_teacher_select') THEN
    EXECUTE '
      CREATE POLICY lessons_teacher_select ON public.lessons FOR SELECT
      USING (teacher_id = auth.uid()::text)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'lessons_teacher_insert') THEN
    EXECUTE '
      CREATE POLICY lessons_teacher_insert ON public.lessons FOR INSERT
      WITH CHECK (teacher_id = auth.uid()::text)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'lessons_teacher_update') THEN
    EXECUTE '
      CREATE POLICY lessons_teacher_update ON public.lessons FOR UPDATE
      USING (teacher_id = auth.uid()::text)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'lessons_teacher_delete') THEN
    EXECUTE '
      CREATE POLICY lessons_teacher_delete ON public.lessons FOR DELETE
      USING (teacher_id = auth.uid()::text)';
  END IF;
END$$;

-- Students can read published lessons
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'lessons_student_select') THEN
    EXECUTE '
      CREATE POLICY lessons_student_select ON public.lessons FOR SELECT
      USING (is_published = true)';
  END IF;
END$$;

-- Admins can read all lessons
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'lessons_admin_select') THEN
    EXECUTE '
      CREATE POLICY lessons_admin_select ON public.lessons FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role = ''admin''
        )
      )';
  END IF;
END$$;

-- Admins can update all lessons (publish/unpublish)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'lessons_admin_update') THEN
    EXECUTE '
      CREATE POLICY lessons_admin_update ON public.lessons FOR UPDATE
      USING (
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role = ''admin''
        )
      )';
  END IF;
END$$;

-- Admins can delete any lesson
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'lessons_admin_delete') THEN
    EXECUTE '
      CREATE POLICY lessons_admin_delete ON public.lessons FOR DELETE
      USING (
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role = ''admin''
        )
      )';
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_lessons_teacher ON public.lessons (teacher_id);
CREATE INDEX IF NOT EXISTS idx_lessons_published ON public.lessons (is_published);

-- Updated_at trigger
DROP TRIGGER IF EXISTS update_lessons_updated_at ON public.lessons;
CREATE TRIGGER update_lessons_updated_at
  BEFORE UPDATE ON public.lessons
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- 4. CREATE QUIZZES TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS public.quizzes (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id         TEXT NOT NULL,
  title             TEXT NOT NULL,
  description       TEXT DEFAULT '',
  time_limit_minutes INTEGER DEFAULT 0,
  passing_score     INTEGER DEFAULT 60,
  order_index       INTEGER DEFAULT 0,
  is_published      BOOLEAN DEFAULT false,
  sync_status       TEXT DEFAULT 'synced',
  created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'quizzes_select_published') THEN
    EXECUTE '
      CREATE POLICY quizzes_select_published ON public.quizzes FOR SELECT
      USING (is_published = true)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'quizzes_teacher_all') THEN
    EXECUTE '
      CREATE POLICY quizzes_teacher_all ON public.quizzes FOR ALL
      USING (
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role IN (''teacher'', ''admin'')
        )
      )';
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_quizzes_lesson ON public.quizzes (lesson_id);

-- =============================================
-- 5. CREATE QUESTIONS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS public.questions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id       TEXT NOT NULL,
  question_text TEXT NOT NULL,
  question_type TEXT NOT NULL DEFAULT 'multiple_choice',
  options       JSONB DEFAULT '[]'::jsonb,
  correct_answer TEXT NOT NULL,
  order_index   INTEGER DEFAULT 0,
  points        INTEGER DEFAULT 1,
  sync_status   TEXT DEFAULT 'synced',
  created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'questions_authenticated_select') THEN
    EXECUTE '
      CREATE POLICY questions_authenticated_select ON public.questions FOR SELECT
      USING (auth.uid() IS NOT NULL)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'questions_teacher_all') THEN
    EXECUTE '
      CREATE POLICY questions_teacher_all ON public.questions FOR ALL
      USING (
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role IN (''teacher'', ''admin'')
        )
      )';
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_questions_quiz ON public.questions (quiz_id);

-- =============================================
-- 6. CREATE PROGRESS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS public.progress (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id        TEXT NOT NULL,
  lesson_id         TEXT NOT NULL,
  quiz_id           TEXT,
  progress_percent  DOUBLE PRECISION DEFAULT 0.0,
  quiz_score        INTEGER,
  time_spent_minutes INTEGER DEFAULT 0,
  sync_status       TEXT DEFAULT 'synced',
  last_accessed_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(student_id, lesson_id)
);

ALTER TABLE public.progress ENABLE ROW LEVEL SECURITY;

-- Students can CRUD their own progress
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'progress_student_select') THEN
    EXECUTE '
      CREATE POLICY progress_student_select ON public.progress FOR SELECT
      USING (student_id = auth.uid()::text)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'progress_student_insert') THEN
    EXECUTE '
      CREATE POLICY progress_student_insert ON public.progress FOR INSERT
      WITH CHECK (student_id = auth.uid()::text)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'progress_student_update') THEN
    EXECUTE '
      CREATE POLICY progress_student_update ON public.progress FOR UPDATE
      USING (student_id = auth.uid()::text)';
  END IF;
END$$;

-- Teachers can view their students' progress
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'progress_teacher_select') THEN
    EXECUTE '
      CREATE POLICY progress_teacher_select ON public.progress FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role IN (''teacher'', ''admin'')
        )
      )';
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_progress_student ON public.progress (student_id);
CREATE INDEX IF NOT EXISTS idx_progress_lesson ON public.progress (lesson_id);

-- =============================================
-- 7. CREATE SESSIONS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS public.sessions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id    TEXT NOT NULL,
  title         TEXT NOT NULL,
  description   TEXT DEFAULT '',
  scheduled_at  TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  location      TEXT,
  status        TEXT DEFAULT 'scheduled',
  sync_status   TEXT DEFAULT 'synced',
  created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'sessions_teacher_all') THEN
    EXECUTE '
      CREATE POLICY sessions_teacher_all ON public.sessions FOR ALL
      USING (teacher_id = auth.uid()::text)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'sessions_student_select') THEN
    EXECUTE '
      CREATE POLICY sessions_student_select ON public.sessions FOR SELECT
      USING (auth.uid() IS NOT NULL)';
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_sessions_teacher ON public.sessions (teacher_id);

-- =============================================
-- 8. CREATE ANNOUNCEMENTS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS public.announcements (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id  TEXT NOT NULL,
  title       TEXT NOT NULL,
  message     TEXT NOT NULL,
  target      JSONB DEFAULT '{}'::jsonb,
  is_pinned   BOOLEAN DEFAULT false,
  sync_status TEXT DEFAULT 'synced',
  created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'announcements_teacher_all') THEN
    EXECUTE '
      CREATE POLICY announcements_teacher_all ON public.announcements FOR ALL
      USING (teacher_id = auth.uid()::text)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'announcements_student_select') THEN
    EXECUTE '
      CREATE POLICY announcements_student_select ON public.announcements FOR SELECT
      USING (auth.uid() IS NOT NULL)';
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_announcements_teacher ON public.announcements (teacher_id);

-- =============================================
-- 9. CREATE DOWNLOADS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS public.downloads (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id         TEXT NOT NULL,
  student_id        TEXT NOT NULL,
  local_file_path   TEXT,
  download_progress DOUBLE PRECISION DEFAULT 0.0,
  status            TEXT DEFAULT 'notDownloaded',
  file_size_bytes   BIGINT DEFAULT 0,
  created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.downloads ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'downloads_student_all') THEN
    EXECUTE '
      CREATE POLICY downloads_student_all ON public.downloads FOR ALL
      USING (student_id = auth.uid()::text)';
  END IF;
END$$;

-- =============================================
-- 10. ADMIN RLS POLICIES ON USERS TABLE
-- =============================================

-- Admin can update any user (approve teachers, change roles, etc.)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'users_admin_update') THEN
    EXECUTE '
      CREATE POLICY users_admin_update ON public.users FOR UPDATE
      USING (
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role = ''admin''
        )
      )';
  END IF;
END$$;

-- Admin can view all users
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'users_admin_select') THEN
    EXECUTE '
      CREATE POLICY users_admin_select ON public.users FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role = ''admin''
        )
      )';
  END IF;
END$$;

-- Admin can delete users
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'users_admin_delete') THEN
    EXECUTE '
      CREATE POLICY users_admin_delete ON public.users FOR DELETE
      USING (
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role = ''admin''
        )
      )';
  END IF;
END$$;

-- =============================================
-- 11. STORAGE BUCKET POLICIES (run in Supabase Dashboard)
-- =============================================

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES ('lesson-videos', 'lesson-videos', false) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('lesson-materials', 'lesson-materials', false) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('profile-pictures', 'profile-pictures', true) ON CONFLICT DO NOTHING;

-- Storage policies: teachers can upload to lesson-videos
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'lesson_videos_teacher_insert') THEN
    EXECUTE '
      CREATE POLICY lesson_videos_teacher_insert ON storage.objects FOR INSERT
      WITH CHECK (
        bucket_id = ''lesson-videos'' AND
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role IN (''teacher'', ''admin'')
        )
      )';
  END IF;
END$$;

-- Authenticated users can read lesson videos
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'lesson_videos_authenticated_select') THEN
    EXECUTE '
      CREATE POLICY lesson_videos_authenticated_select ON storage.objects FOR SELECT
      USING (bucket_id = ''lesson-videos'' AND auth.uid() IS NOT NULL)';
  END IF;
END$$;

-- Teachers can upload to lesson-materials
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'lesson_materials_teacher_insert') THEN
    EXECUTE '
      CREATE POLICY lesson_materials_teacher_insert ON storage.objects FOR INSERT
      WITH CHECK (
        bucket_id = ''lesson-materials'' AND
        EXISTS (
          SELECT 1 FROM public.users u WHERE u.id::text = auth.uid()::text AND u.role IN (''teacher'', ''admin'')
        )
      )';
  END IF;
END$$;

-- Authenticated users can read lesson materials
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'lesson_materials_authenticated_select') THEN
    EXECUTE '
      CREATE POLICY lesson_materials_authenticated_select ON storage.objects FOR SELECT
      USING (bucket_id = ''lesson-materials'' AND auth.uid() IS NOT NULL)';
  END IF;
END$$;

-- Users can upload their own profile pictures
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'profile_pictures_owner_insert') THEN
    EXECUTE '
      CREATE POLICY profile_pictures_owner_insert ON storage.objects FOR INSERT
      WITH CHECK (
        bucket_id = ''profile-pictures'' AND
        (storage.foldername(name))[1] = auth.uid()::text
      )';
  END IF;
END$$;

-- Profile pictures are publicly readable
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'profile_pictures_public_select') THEN
    EXECUTE '
      CREATE POLICY profile_pictures_public_select ON storage.objects FOR SELECT
      USING (bucket_id = ''profile-pictures'')';
  END IF;
END$$;

-- =============================================
-- 12. SERVER-SIDE VALIDATION TRIGGERS
-- =============================================

-- Validate email format on user insert/update
CREATE OR REPLACE FUNCTION validate_user_email()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.email IS NULL OR NEW.email !~ '^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$' THEN
    RAISE EXCEPTION 'Invalid email format: %', NEW.email;
  END IF;
  IF NEW."fullName" IS NULL OR LENGTH(TRIM(NEW."fullName")) < 2 THEN
    RAISE EXCEPTION 'Full name must be at least 2 characters';
  END IF;
  IF NEW.role NOT IN ('student', 'teacher', 'admin') THEN
    RAISE EXCEPTION 'Invalid role: %', NEW.role;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_user_before_insert ON public.users;
CREATE TRIGGER validate_user_before_insert
  BEFORE INSERT ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION validate_user_email();

DROP TRIGGER IF EXISTS validate_user_before_update ON public.users;
CREATE TRIGGER validate_user_before_update
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION validate_user_email();

-- Validate lesson data
CREATE OR REPLACE FUNCTION validate_lesson()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.title IS NULL OR LENGTH(TRIM(NEW.title)) < 1 THEN
    RAISE EXCEPTION 'Lesson title is required';
  END IF;
  IF NEW.subject IS NULL OR LENGTH(TRIM(NEW.subject)) < 1 THEN
    RAISE EXCEPTION 'Lesson subject is required';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_lesson_before_insert ON public.lessons;
CREATE TRIGGER validate_lesson_before_insert
  BEFORE INSERT ON public.lessons
  FOR EACH ROW
  EXECUTE FUNCTION validate_lesson();

-- Validate quiz score range
CREATE OR REPLACE FUNCTION validate_progress()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.progress_percent < 0 OR NEW.progress_percent > 100 THEN
    RAISE EXCEPTION 'Progress percent must be between 0 and 100';
  END IF;
  IF NEW.quiz_score IS NOT NULL AND (NEW.quiz_score < 0 OR NEW.quiz_score > 100) THEN
    RAISE EXCEPTION 'Quiz score must be between 0 and 100';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_progress_before_insert ON public.progress;
CREATE TRIGGER validate_progress_before_insert
  BEFORE INSERT ON public.progress
  FOR EACH ROW
  EXECUTE FUNCTION validate_progress();

DROP TRIGGER IF EXISTS validate_progress_before_update ON public.progress;
CREATE TRIGGER validate_progress_before_update
  BEFORE UPDATE ON public.progress
  FOR EACH ROW
  EXECUTE FUNCTION validate_progress();
