# Developer setup — ALS Study Companion

This guide covers local setup for development across the mono-repo packages: `mobile_app`, `admin_web`, `backend_services`, and `shared_core`.

Prerequisites
- Install Flutter (stable) and Dart. Recommended SDK: 3.11.x.
- Install `supabase` CLI if you plan to run migrations locally (optional): https://supabase.com/docs/guides/cli
- Node.js (for optional root helper scripts), and `npm`.

Initial steps
1. From repo root, fetch dependencies for the Flutter packages:

```bash
flutter pub get
```

2. For package-local development, `cd` into the package and run `flutter pub get` again. Example:

```bash
cd als_study_companion/mobile_app
flutter pub get
```

Running tests
- Run all Flutter tests from a package:

```bash
flutter test
```

Supabase & database
- SQL migrations live in `supabase/migrations` and `als_study_companion/supabase/migrations`.
- To apply migrations locally, install the Supabase CLI and follow its docs. Example (after login):

```bash
supabase db reset  # WARNING: destructive on local DB
supabase db push
```

Environment variables
- Example env files are provided: `/.env.example` and `als_study_companion/mobile_app/.env.example`.
- Copy to `.env` and populate `SUPABASE_URL`, `SUPABASE_ANON_KEY`, etc.

CI
- A GitHub Actions workflow is included at `.github/workflows/flutter-ci.yml` to run `flutter pub get` and `flutter test` across packages.

Notes
- Keep `pubspec.lock` generated locally; lockfiles should be committed per package if you want deterministic installs.
- If Flutter is not installed on your CI runner, update the workflow to use `subosito/flutter-action` which sets it up.

If anything here fails on your machine, copy the exact error and open an issue.
