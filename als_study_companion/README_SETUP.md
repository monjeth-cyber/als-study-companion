**ALS Study Companion — Setup & Online MUSTs**

This document lists the required local steps and the required online (Firebase) steps to get the full monorepo running.

**Prerequisites**

- Flutter SDK (stable) installed and on PATH
- Dart SDK (bundled with Flutter)
- Firebase CLI and FlutterFire CLI installed
  - Firebase CLI: https://firebase.google.com/docs/cli
  - FlutterFire CLI: https://firebase.flutter.dev/docs/cli
- Android or iOS platform SDKs if running mobile

**Required online (MUST) steps — Firebase**

1. Create a Firebase project (or one per environment).
2. Enable these Firebase products:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Firebase Storage
3. Register platform apps in the Firebase project:
   - Android app: register package name (e.g. com.als.mobile_app). Download `google-services.json` and place into `mobile_app/android/app/`.
   - iOS app: register bundle id and add `GoogleService-Info.plist` to `mobile_app/ios/Runner/`.
   - Web app: register a Web app to obtain the firebase config snippet for `admin_web`.
4. Set Firestore rules and Storage rules appropriate for your environment.
5. (Optional) Create service accounts for server-side tasks. DO NOT commit service account JSON files.

**Local setup (monorepo)**

Run these commands from the repo `als_study_companion` root.

```bash
# Pull dependencies for each package
cd shared_core; flutter pub get
cd ../backend_services; flutter pub get
cd ../mobile_app; flutter pub get
cd ../admin_web; flutter pub get
```

**Configure Firebase with FlutterFire CLI (recommended)**

```bash
# from repo root or per-app folder
flutterfire configure --project <FIREBASE_PROJECT_ID>
```

If the CLI is not appropriate, copy platform config files manually (see above).

**Run apps**

- Mobile (device/emulator):

```bash
cd mobile_app
flutter run
```

- Admin web (Chrome):

```bash
cd admin_web
flutter run -d chrome --web-renderer html
```

**Static checks & tests**

```bash
cd shared_core; flutter analyze
cd ../backend_services; flutter analyze
cd ../mobile_app; flutter analyze
cd ../admin_web; flutter analyze

# Run tests
cd mobile_app; flutter test
cd shared_core; flutter test
cd backend_services; flutter test
cd admin_web; flutter test
```

**Important security notes (MUST)**

- Never commit `google-services.json`, `GoogleService-Info.plist`, or service account JSONs.
- Use environment variables or CI secrets for production credentials.

**Monorepo notes**

- Local path dependencies are used for `shared_core` — this is normal for development.
- `backend_services` is marked non-publishable (`publish_to: 'none'`) to avoid publish-time errors.

**If you'd like help**

- I can run `flutterfire configure` for you if you provide the Firebase project id and confirm platform IDs.
- I can add a minimal GitHub Actions workflow to run analysis and tests for each package.

---

Last updated: March 4, 2026
