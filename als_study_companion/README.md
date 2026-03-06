# ALS Study Companion

A Flutter-based learning management system for the Alternative Learning System (ALS) in the Philippines. Supports students, teachers, and administrators with offline-first architecture.

## Architecture

- **mobile_app/** — Student & Teacher mobile app (Flutter + Provider MVVM)
- **admin_web/** — Administrator web dashboard (Flutter Web)
- **backend_services/** — Shared backend logic (Supabase client, sync service)
- **shared_core/** — Models, enums, validators, constants shared across all packages

## Key Features

### Students
- Google Sign-In + email/password authentication
- Email verification gate before access
- Lesson browsing and video playback
- Quiz taking with progress tracking
- Offline downloads with progress indicators
- Progress export to CSV

### Teachers
- Registration with admin approval workflow
- Lesson creation with video & material uploads (progress tracking)
- Class session management
- Announcements

### Administrators (Web)
- User management (search, role changes, bulk CSV import)
- Content moderation (publish/unpublish lessons, delete)
- Teacher approval/revocation
- Analytics dashboard with real Supabase data
- Audit logging for all admin actions

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile UI | Flutter 3.x, Provider |
| Web UI | Flutter Web |
| Auth | Firebase Auth + Supabase Auth |
| Cloud DB | Supabase (PostgreSQL + RLS) |
| Local DB | Drift (SQLite) + sqflite |
| Storage | Supabase Storage |
| Sync | Offline-first with exponential backoff |

## Getting Started

```bash
# Install dependencies for all packages
cd shared_core && flutter pub get && cd ..
cd backend_services && flutter pub get && cd ..
cd mobile_app && flutter pub get && cd ..
cd admin_web && flutter pub get && cd ..

# Generate Drift database code
cd mobile_app && dart run build_runner build --delete-conflicting-outputs

# Run mobile app
cd mobile_app && flutter run

# Run admin web
cd admin_web && flutter run -d chrome
```

## Supabase Setup

See [mobile_app/SUPABASE_SETUP.md](mobile_app/SUPABASE_SETUP.md) for full setup instructions including the comprehensive schema migration.

## Running Tests

```bash
cd shared_core && flutter test
cd backend_services && flutter test
cd mobile_app && flutter test
cd admin_web && flutter test
```
