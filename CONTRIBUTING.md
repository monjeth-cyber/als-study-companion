# Contributing

Thanks for contributing to ALS Study Companion! Quick guidelines:

- Fork the repo and open a PR against `main`.
- Run `flutter pub get` in affected packages and ensure tests pass.
- Follow existing lint rules. Run `dart analyze` and `flutter test`.
- For breaking changes, add migration notes and update `docs/SETUP.md`.

Reporting issues
- Create issues with a concise reproduction and environment details (OS, Flutter SDK, Dart).

Coding standards
- Follow the `flutter_lints` rules present in packages; add a focused unit test for new logic.
