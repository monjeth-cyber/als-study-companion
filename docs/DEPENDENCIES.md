# Dependency audit

Summary of `flutter pub outdated` checks (March 8, 2026):

- `mobile_app` has several packages with newer major versions available (e.g., `connectivity_plus 7.0.0`, `google_sign_in 7.x`, `drift 2.32.0`, `flutter_dotenv 6.0.0`). One package (`js`) is discontinued.
- `backend_services` shows `connectivity_plus` can be updated to `7.0.0` and a few transitive updates are available.
- `shared_core` and `admin_web` have mostly up-to-date direct dependencies but some transitive packages (analyzer-related) have newer releases.

Recommended actions

1. Run `flutter pub upgrade` in a feature branch, then run `flutter test` and `flutter analyze` for each package.

```bash
cd als_study_companion/mobile_app
flutter pub upgrade
flutter test
flutter analyze
```

2. For major-version bumps (e.g., `connectivity_plus` 6 → 7 or `google_sign_in` 6 → 7), check changelogs for breaking changes and update code accordingly.

3. Replace discontinued packages (e.g., `js`) if they are used, or remove them from `pubspec.yaml`.

4. Consider locking dependency ranges in `pubspec.yaml` to avoid accidental major upgrades in CI; commit `pubspec.lock` files for deterministic installs if desired.

5. If you rely on `drift`/`drift_dev` code generation, run `flutter pub run build_runner build --delete-conflicting-outputs` after upgrades.

If you want, I can open a PR that updates direct dependencies incrementally (minor/patch first, then major upgrades with code changes and tests).
