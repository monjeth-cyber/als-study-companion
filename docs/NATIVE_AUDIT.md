# Native configuration audit (Android / iOS)

Checklist to verify native mobile app configs before CI and releases:

- Android
  - [ ] `android/local.properties` is present locally (not committed). CI should NOT rely on it.
  - [ ] Keystore: ensure `keystore.properties` or GitHub secrets used for signing on CI.
  - [ ] `android/app/build.gradle` uses `signingConfig` only when signing is configured.
  - [ ] Confirm `minSdkVersion` and `targetSdkVersion` meet project requirements.

- iOS
  - [ ] `ios/Runner.xcodeproj` / `Runner.xcworkspace` present.
  - [ ] Provisioning profiles and code signing set up for CI (use `match` or GitHub secrets).
  - [ ] Verify `Info.plist` privacy strings for camera/microphone if used.

Audit commands

```bash
# Check for local.properties (Android) - should be local only
ls als_study_companion/mobile_app/android/local.properties || true

# Basic Android build (CI should set signing vars)
cd als_study_companion/mobile_app
flutter build apk --release
```

If you want, I can run a shallow audit that checks for the presence of `local.properties`, `keystore.properties`, and common signing configuration in `build.gradle` and produce a report.
