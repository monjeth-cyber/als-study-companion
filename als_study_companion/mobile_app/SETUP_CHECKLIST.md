# Supabase Migration Checklist

Use this checklist to track your migration progress.

## Phase 1: Initial Setup ⚙️

- [ ] Create Supabase account at https://supabase.com
- [ ] Create new Supabase project
- [ ] Wait for database provisioning (2-3 minutes)
- [ ] Copy Project URL from Settings → API
- [ ] Copy anon key from Settings → API
- [ ] Create `.env` file from `.env.example`
- [ ] Paste credentials into `.env` file
- [ ] Run `flutter pub get` in mobile_app directory
- [ ] Run `dart run build_runner build` to generate database code

## Phase 2: Database Setup 🗄️

- [ ] Open Supabase Dashboard → SQL Editor
- [ ] Copy contents of `supabase_schema.sql`
- [ ] Paste and run in SQL Editor
- [ ] Verify users table created (check Tables in sidebar)
- [ ] Verify RLS policies created (Authentication → Policies)
- [ ] Verify trigger created for updatedAt

## Phase 3: Test Authentication 🔐

- [ ] Disable email confirmation (Settings → Authentication → Email)
  - [ ] Turn OFF "Enable email confirmations" (for dev only)
- [ ] Create test user in Dashboard → Authentication → Users
  - Email: your-test@email.com
  - Password: (choose a password)
  - Copy the generated UUID
- [ ] Add user profile to users table:
  ```sql
  INSERT INTO users (id, email, "fullName", role)
  VALUES (
    'PASTE-UUID-HERE',
    'your-test@email.com',
    'Test User',
    'student'
  );
  ```
- [ ] Run the INSERT query in SQL Editor
- [ ] Verify user appears in users table

## Phase 4: Run the App 🚀

- [ ] Connect device or start emulator
- [ ] Run `flutter run` in mobile_app directory
- [ ] Wait for app to build and launch
- [ ] See login screen
- [ ] Enter test email and password
- [ ] Click Sign In
- [ ] Successfully navigate to Student Dashboard
- [ ] Test sign out functionality

## Phase 5: Verify Features ✅

- [ ] Login works with correct credentials
- [ ] Login fails with wrong credentials
- [ ] Error messages display correctly
- [ ] User role-based navigation works (student → student dashboard)
- [ ] Sign out returns to login screen
- [ ] App remembers session (close and reopen app)

## Phase 6: Create Second Test User (Teacher) 👨‍🏫

- [ ] Create another auth user in Supabase Dashboard
- [ ] Add profile with role='teacher'
- [ ] Test login as teacher
- [ ] Verify navigation to Teacher Dashboard
- [ ] Test switching between accounts

## Phase 7: Offline Testing 📴

- [ ] Login while online
- [ ] Turn off WiFi/data
- [ ] Close and reopen app
- [ ] Verify cached user still loads
- [ ] Verify offline functionality (limited)
- [ ] Turn on WiFi/data
- [ ] Verify sync resumes

## Phase 8: Optional Enhancements 🎨

- [ ] Create registration view
- [ ] Implement password reset flow
- [ ] Add email verification check
- [ ] Create sync worker for background sync
- [ ] Add profile picture upload
- [ ] Implement user profile editing

## Phase 9: Data Migration (if from Firebase) 📦

- [ ] Export Firestore users collection
- [ ] Transform to Postgres format
- [ ] Import into Supabase users table
- [ ] Verify all users imported correctly
- [ ] Send password reset emails to all users
- [ ] Export lessons data
- [ ] Import lessons to Supabase
- [ ] Export progress data
- [ ] Import progress to Supabase
- [ ] Migrate file storage
- [ ] Test all migrated data

## Phase 10: Production Preparation 🏭

- [ ] Review and tighten RLS policies
- [ ] Enable email confirmations
- [ ] Set up custom email templates
- [ ] Configure rate limiting
- [ ] Set up monitoring/alerts
- [ ] Create production `.env` (different from dev)
- [ ] Test on production Supabase instance
- [ ] Create rollback plan
- [ ] Document for team

## Phase 11: Go Live 🎉

- [ ] Update production environment variables
- [ ] Deploy updated app
- [ ] Monitor error logs
- [ ] Watch authentication metrics
- [ ] Collect user feedback
- [ ] Address any issues quickly

## Phase 12: Cleanup 🧹

- [ ] Remove Firebase dependencies from pubspec.yaml
- [ ] Delete Firebase service files
- [ ] Remove Firebase initialization code
- [ ] Update documentation
- [ ] Archive Firebase project (don't delete immediately)
- [ ] Celebrate successful migration! 🎊

---

## Quick Commands Reference

```bash
# Install dependencies
cd mobile_app
flutter pub get

# Generate database code
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Hot reload (while app is running)
# Press 'r' in terminal

# Clean build (if issues)
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run

# Check for outdated packages
flutter pub outdated

# Update packages
flutter pub upgrade
```

## Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| "Invalid API key" | Check `.env` file exists and has correct keys |
| "relation 'users' does not exist" | Run `supabase_schema.sql` in SQL Editor |
| Build errors with drift | Run `dart run build_runner build --delete-conflicting-outputs` |
| Login fails | Verify user exists in both auth.users AND users table |
| App crashes on startup | Check Supabase URL in .env is correct |
| "No such file: .env" | Ensure .env is in mobile_app root, add to assets in pubspec.yaml |

---

**Current Progress**: Track by checking off items as you complete them!

**Estimated Time**: 
- Initial Setup: 30 minutes
- Testing: 15 minutes
- Migration (if applicable): 2-8 hours depending on data size
