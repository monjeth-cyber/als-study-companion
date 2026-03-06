-- ALS Study Companion - Supabase Database Schema
-- Run this in Supabase Dashboard → SQL Editor

-- ============================================
-- CREATE USERS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  "fullName" TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('student', 'teacher', 'admin')),
  "profilePictureUrl" TEXT,
  "alsCenterId" TEXT,
  "isActive" BOOLEAN DEFAULT true,
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- ============================================
-- CREATE RLS POLICIES
-- ============================================

-- Policy: Users can read their own data
DROP POLICY IF EXISTS "Users can view own profile" ON users;
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can update their own data
DROP POLICY IF EXISTS "Users can update own profile" ON users;
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Policy: System can insert (for registration)
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON users;
CREATE POLICY "Enable insert for authenticated users"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Policy: Teachers/Admins can view all users (optional - adjust as needed)
DROP POLICY IF EXISTS "Teachers and admins can view all users" ON users;
CREATE POLICY "Teachers and admins can view all users"
  ON users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND u.role IN ('teacher', 'admin')
    )
  );

-- ============================================
-- CREATE TRIGGER FOR UPDATED_AT
-- ============================================

-- Function to automatically update updatedAt timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger on users table
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_als_center ON users("alsCenterId") WHERE "alsCenterId" IS NOT NULL;

-- ============================================
-- OPTIONAL: CREATE TEST USER
-- ============================================

-- Uncomment to create a test student user
-- First create the auth user in Dashboard → Authentication → Users
-- Then insert the profile here with matching UUID
/*
INSERT INTO users (id, email, "fullName", role)
VALUES (
  'YOUR-AUTH-USER-UUID-HERE',
  'student@test.com',
  'Test Student',
  'student'
)
ON CONFLICT (id) DO NOTHING;
*/

-- ============================================
-- VERIFY SETUP
-- ============================================

-- Check that table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_name = 'users'
) AS users_table_exists;

-- Check policies
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename = 'users';

-- ============================================
-- FUTURE TABLES (Add as needed)
-- ============================================

-- Example lessons table structure
/*
CREATE TABLE IF NOT EXISTS lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  "moduleId" TEXT,
  "contentUrl" TEXT,
  "thumbnailUrl" TEXT,
  "createdBy" UUID REFERENCES users(id),
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
*/

-- Example progress table structure
/*
CREATE TABLE IF NOT EXISTS progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId" UUID REFERENCES users(id) ON DELETE CASCADE,
  "lessonId" UUID REFERENCES lessons(id) ON DELETE CASCADE,
  status TEXT CHECK (status IN ('not_started', 'in_progress', 'completed')),
  "progressPercentage" INTEGER DEFAULT 0,
  "lastAccessedAt" TIMESTAMP WITH TIME ZONE,
  "completedAt" TIMESTAMP WITH TIME ZONE,
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE("userId", "lessonId")
);
*/
