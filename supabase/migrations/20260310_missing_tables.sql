-- Migration: Add missing tables that have models in the app but no Supabase table.
-- Tables added: als_centers, students, teachers
-- Also ensures update_updated_at_column() exists before dependent triggers.

-- =============================================
-- 0. ENSURE HELPER FUNCTION EXISTS
--    (originally in supabase_schema.sql but needed by all trigger blocks)
-- =============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- 1. ALS CENTERS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS public.als_centers (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name             TEXT NOT NULL,
  address          TEXT NOT NULL,
  region           TEXT NOT NULL,
  contact_number   TEXT,
  head_teacher_id  TEXT,            -- references users.id loosely
  is_active        BOOLEAN DEFAULT true,
  created_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.als_centers ENABLE ROW LEVEL SECURITY;

-- Anyone authenticated can view centers
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'als_centers_authenticated_select') THEN
    EXECUTE '
      CREATE POLICY als_centers_authenticated_select ON public.als_centers FOR SELECT
      USING (auth.uid() IS NOT NULL)';
  END IF;
END$$;

-- Only admins can create/update/delete centers
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'als_centers_admin_all') THEN
    EXECUTE '
      CREATE POLICY als_centers_admin_all ON public.als_centers FOR ALL
      USING (
        EXISTS (
          SELECT 1 FROM public.users u
          WHERE u.id::text = auth.uid()::text AND u.role = ''admin''
        )
      )';
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_als_centers_region ON public.als_centers (region);

DROP TRIGGER IF EXISTS update_als_centers_updated_at ON public.als_centers;
CREATE TRIGGER update_als_centers_updated_at
  BEFORE UPDATE ON public.als_centers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- 2. STUDENTS TABLE
--    Stores student-specific profile data.
--    user_id links to public.users.id (and auth.users.id).
-- =============================================

CREATE TABLE IF NOT EXISTS public.students (
  id                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                    TEXT NOT NULL UNIQUE,   -- FK to users.id
  learner_reference_number   TEXT UNIQUE,            -- 12-digit DepEd LRN
  student_id_number          TEXT,
  grade_level                TEXT NOT NULL DEFAULT 'BLP',
  enrollment_date            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  guardian_name              TEXT,
  guardian_contact           TEXT,
  date_of_birth              DATE,
  age                        INTEGER,
  occupation                 TEXT,
  last_school_attended       TEXT,
  last_year_attended         TEXT,
  als_center_id              TEXT,                  -- FK to als_centers.id
  is_active                  BOOLEAN DEFAULT true,
  created_at                 TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at                 TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

-- Students can read and update their own profile
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'students_own_select') THEN
    EXECUTE '
      CREATE POLICY students_own_select ON public.students FOR SELECT
      USING (user_id = auth.uid()::text)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'students_own_insert') THEN
    EXECUTE '
      CREATE POLICY students_own_insert ON public.students FOR INSERT
      WITH CHECK (user_id = auth.uid()::text)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'students_own_update') THEN
    EXECUTE '
      CREATE POLICY students_own_update ON public.students FOR UPDATE
      USING (user_id = auth.uid()::text)';
  END IF;
END$$;

-- Teachers can view all students
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'students_teacher_select') THEN
    EXECUTE '
      CREATE POLICY students_teacher_select ON public.students FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM public.users u
          WHERE u.id::text = auth.uid()::text AND u.role IN (''teacher'', ''admin'')
        )
      )';
  END IF;
END$$;

-- Admins full access
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'students_admin_all') THEN
    EXECUTE '
      CREATE POLICY students_admin_all ON public.students FOR ALL
      USING (
        EXISTS (
          SELECT 1 FROM public.users u
          WHERE u.id::text = auth.uid()::text AND u.role = ''admin''
        )
      )';
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_students_user_id    ON public.students (user_id);
CREATE INDEX IF NOT EXISTS idx_students_lrn        ON public.students (learner_reference_number);
CREATE INDEX IF NOT EXISTS idx_students_center     ON public.students (als_center_id);

DROP TRIGGER IF EXISTS update_students_updated_at ON public.students;
CREATE TRIGGER update_students_updated_at
  BEFORE UPDATE ON public.students
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Validate LRN is exactly 12 digits when provided
CREATE OR REPLACE FUNCTION validate_student_lrn()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.learner_reference_number IS NOT NULL AND
     NEW.learner_reference_number !~ '^\d{12}$' THEN
    RAISE EXCEPTION 'LRN must be exactly 12 digits: %', NEW.learner_reference_number;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_student_before_insert ON public.students;
CREATE TRIGGER validate_student_before_insert
  BEFORE INSERT ON public.students
  FOR EACH ROW EXECUTE FUNCTION validate_student_lrn();

DROP TRIGGER IF EXISTS validate_student_before_update ON public.students;
CREATE TRIGGER validate_student_before_update
  BEFORE UPDATE ON public.students
  FOR EACH ROW EXECUTE FUNCTION validate_student_lrn();

-- =============================================
-- 3. TEACHERS TABLE
--    Stores teacher-specific profile data.
-- =============================================

CREATE TABLE IF NOT EXISTS public.teachers (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               TEXT NOT NULL UNIQUE,   -- FK to users.id
  als_center_id         TEXT,                   -- FK to als_centers.id
  employee_id           TEXT UNIQUE,
  specialization        TEXT NOT NULL DEFAULT '',
  assigned_student_ids  TEXT DEFAULT '',        -- comma-separated student ids
  is_active             BOOLEAN DEFAULT true,
  created_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;

-- Teachers can read and update their own profile
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'teachers_own_select') THEN
    EXECUTE '
      CREATE POLICY teachers_own_select ON public.teachers FOR SELECT
      USING (user_id = auth.uid()::text)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'teachers_own_insert') THEN
    EXECUTE '
      CREATE POLICY teachers_own_insert ON public.teachers FOR INSERT
      WITH CHECK (user_id = auth.uid()::text)';
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'teachers_own_update') THEN
    EXECUTE '
      CREATE POLICY teachers_own_update ON public.teachers FOR UPDATE
      USING (user_id = auth.uid()::text)';
  END IF;
END$$;

-- Admins can view and manage all teachers
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'teachers_admin_all') THEN
    EXECUTE '
      CREATE POLICY teachers_admin_all ON public.teachers FOR ALL
      USING (
        EXISTS (
          SELECT 1 FROM public.users u
          WHERE u.id::text = auth.uid()::text AND u.role = ''admin''
        )
      )';
  END IF;
END$$;

-- Students can see basic teacher info
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'teachers_student_select') THEN
    EXECUTE '
      CREATE POLICY teachers_student_select ON public.teachers FOR SELECT
      USING (auth.uid() IS NOT NULL)';
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_teachers_user_id  ON public.teachers (user_id);
CREATE INDEX IF NOT EXISTS idx_teachers_center   ON public.teachers (als_center_id);

DROP TRIGGER IF EXISTS update_teachers_updated_at ON public.teachers;
CREATE TRIGGER update_teachers_updated_at
  BEFORE UPDATE ON public.teachers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- 4. FIX: ENSURE updated_at EXISTS ON TABLES
--    CREATED BY 20260309 THAT MAY USE CAMEL updated_at
-- =============================================

-- The quizzes, questions, sessions, announcements tables in the comprehensive
-- migration reference updated_at in snake_case, which is correct.
-- Add triggers for tables that had no trigger block in 20260309:

DROP TRIGGER IF EXISTS update_quizzes_updated_at ON public.quizzes;
CREATE TRIGGER update_quizzes_updated_at
  BEFORE UPDATE ON public.quizzes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_questions_updated_at ON public.questions;
CREATE TRIGGER update_questions_updated_at
  BEFORE UPDATE ON public.questions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_sessions_updated_at ON public.sessions;
CREATE TRIGGER update_sessions_updated_at
  BEFORE UPDATE ON public.sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_announcements_updated_at ON public.announcements;
CREATE TRIGGER update_announcements_updated_at
  BEFORE UPDATE ON public.announcements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_progress_updated_at ON public.progress;
CREATE TRIGGER update_progress_updated_at
  BEFORE UPDATE ON public.progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_downloads_updated_at ON public.downloads;
CREATE TRIGGER update_downloads_updated_at
  BEFORE UPDATE ON public.downloads
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
