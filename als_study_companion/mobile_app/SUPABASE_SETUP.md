# Supabase + SQLite Migration Setup Guide

This guide walks through setting up Supabase and SQLite for the ALS Study Companion mobile app.

## Prerequisites

- Flutter SDK installed
- Supabase account (free tier available at https://supabase.com)
- Basic understanding of SQL and database schemas

## Step 1: Create Supabase Project

1. Go to https://supabase.com and sign in
2. Create a new project
3. Wait for the database to be provisioned (~2 minutes)
4. Note your project URL and anon key from Settings > API

## Step 2: Set Up Database Schema

In your Supabase project's SQL Editor, create the users table:

```sql
-- Create users table
CREATE TABLE users (
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

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own data
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can update their own data
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Policy: System can insert (for registration)
CREATE POLICY "Enable insert for authenticated users"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Create function to automatically update updatedAt
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updatedAt
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

## Step 3: Configure Local Environment

1. Copy `.env.example` to `.env`:
   ```bash
   cd mobile_app
   cp .env.example .env
   ```

2. Edit `.env` with your Supabase credentials:
   ```
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your_anon_key_here
   ```

3. **IMPORTANT**: Never commit `.env` to version control (already added to `.gitignore`)

## Step 4: Install Dependencies

Run the following commands:

```bash
cd mobile_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

The second command generates the drift database code.

## Step 5: Test Authentication

1. In Supabase Dashboard, you can manually create test users:
   - Go to Authentication > Users
   - Add a test user with email/password
   - Manually insert a row in the `users` table with matching UUID

2. Or use the app's registration flow (once implemented)

## Step 6: Enable Email Authentication in Supabase

1. In Supabase Dashboard, go to Authentication > Settings
2. Ensure "Enable Email Signups" is ON
3. Configure email templates if needed
4. For development, you might want to disable email confirmation temporarily

## Migration from Firebase

### Export Firestore Users

```bash
# Using gcloud (requires Firebase Admin SDK)
gcloud firestore export gs://your-bucket/users-export --collection-ids=users
```

### Transform and Import

Create a script to transform Firestore documents to Postgres rows:

```javascript
// Example Node.js transformation script
const users = []; // Load from Firestore export
const transformed = users.map(doc => ({
  id: doc.id,
  email: doc.email,
  fullName: doc.fullName,
  role: doc.role,
  alsCenterId: doc.alsCenterId || null,
  isActive: doc.isActive !== false,
  createdAt: doc.createdAt || new Date().toISOString(),
  updatedAt: doc.updatedAt || new Date().toISOString(),
}));

// Import via Supabase client or psql
```

## Architecture Overview

### Supabase (Cloud)
- **Authentication**: Email/password, OAuth
- **Database**: PostgreSQL with Row Level Security
- **Storage**: File uploads (if needed)
- **Realtime**: Websocket subscriptions

### SQLite (Local)
- **Caching**: User profiles, lessons, progress
- **Offline**: Queue for sync when network returns
- **Fast queries**: Local-first reads

### Sync Strategy

1. On login: Fetch user from Supabase → Cache in SQLite
2. On data change: Write to local SQLite → Queue for sync
3. Background worker: Process sync queue when online
4. Conflict resolution: Last-write-wins using `updatedAt` timestamp

## File Structure

```
mobile_app/
├── .env.example          # Template for credentials
├── .env                  # Your credentials (gitignored)
├── lib/
│   ├── core/
│   │   ├── services/
│   │   │   └── supabase_auth_service.dart   # Supabase auth wrapper
│   │   └── local/
│   │       └── local_database.dart           # Drift SQLite DB
│   └── shared/
│       └── viewmodels/
│           └── auth_viewmodel.dart           # Updated for Supabase
└── pubspec.yaml          # Updated dependencies
```

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

## Troubleshooting

### Error: "Invalid API key"
- Check your `.env` file has correct credentials
- Ensure `.env` is in `mobile_app/` directory
- Verify anon key from Supabase Dashboard > Settings > API

### Error: "relation 'users' does not exist"
- Run the SQL schema creation script in Supabase SQL Editor
- Check table name matches exactly (case-sensitive)

### Build errors with drift
- Run: `dart run build_runner build --delete-conflicting-outputs`
- Clean build: `flutter clean && flutter pub get`

### Network issues
- Check Supabase project is active (not paused)
- Verify firewall/proxy settings
- Test with curl: `curl https://your-project.supabase.co`

## Next Steps

1. ✅ Supabase auth integrated
2. ✅ Local SQLite caching setup
3. 🔲 Create registration view
4. 🔲 Implement password reset flow
5. 🔲 Add email verification check
6. 🔲 Migrate lessons/progress data
7. 🔲 Implement background sync worker
8. 🔲 Add conflict resolution logic
9. 🔲 Update admin_web to use Supabase
10. 🔲 Remove Firebase dependencies

## Security Reminders

- ✅ Never commit `.env` file
- ✅ Use anon key in mobile app (public by design)
- ❌ Never put service role key in mobile app
- ✅ Always use Row Level Security policies in Supabase
- ✅ Validate inputs on both client and server
- ✅ Use HTTPS for all requests (Supabase enforces this)

## Resources

- [Supabase Docs](https://supabase.com/docs)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Flutter State Management](https://docs.flutter.dev/data-and-backend/state-mgmt/intro)
