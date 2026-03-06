Supabase setup runbook — ALS Study Companion

Overview
- This runbook explains how to apply the SQL schema, enable RLS, and create storage buckets used by the app.
- Files included: `supabase_schema.sql` (tables, indexes, RLS policies).

Quick apply (recommended path)
1. Open your Supabase project dashboard -> SQL Editor.
2. Copy the contents of `supabase_schema.sql` and run it. This will create tables and RLS policies.

Alternative: use supabase CLI
1. Install the CLI: `npm install -g supabase` or follow Supabase docs.
2. Authenticate: `supabase login` and select project
3. Run SQL file:
   supabase db query --file backend_services/supabase_setup/supabase_schema.sql

Storage buckets
- Create two buckets (via Dashboard -> Storage -> Buckets):
  - `lesson-materials` (private): store lesson attachments and videos
  - `profile-images` (public or private depending on needs)

Suggested storage policies
- For `profile-images`: allow read for public (or provide signed URLs). For uploads, allow only authenticated user to write their own image key.
Example policy (pseudo):
  - allow insert if `request.jwt.claims.user_id = owner_id`
  - allow read via signed URL

JWT claims and roles
- The RLS policies in `supabase_schema.sql` rely on a JWT claim `role` (e.g., 'student' | 'teacher' | 'admin').
- To set custom role claims, provide them when issuing JWTs (or set via Supabase Auth hooks / external JWT issuer). Alternatively, map admin users by UID in a server-side function.

Post-apply checklist
- After applying SQL:
  - Open Supabase Table Editor and verify tables exist.
  - Create initial admin user(s) in `public.users` or set their role claim to 'admin'.
  - Create buckets and test upload/download (use signed URLs for private buckets).
  - Test auth flows from the app (sign up / sign in) and ensure `auth.uid()` matches `public.users.id` where appropriate.

Notes & recommendations
- RLS policies here are conservative examples—adjust to your exact access model (e.g., allow teachers to read progress for their students only).
- For migrations in production, prefer running the SQL in a controlled migration environment (CI or supabase migrations) rather than ad-hoc in the dashboard.
- If you use Supabase Storage privately, generate signed URLs server-side and keep `anon` key restricted in client builds.
