// File generated from google-services.json for project als-study-companion-b85fd.
// Do NOT commit this file if it contains sensitive keys — add to .gitignore.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform not configured in firebase_options.dart. '
        'Run `flutterfire configure` to generate web options.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS not yet configured. Add GoogleService-Info.plist '
          'and run `flutterfire configure` to generate iOS options.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  /// Android config derived from google-services.json.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCs0gohd0e4PhphvH7cdnU8Znipx6pCi20',
    appId: '1:941404387860:android:1aa2d87da0004bbaf6c501',
    messagingSenderId: '941404387860',
    projectId: 'als-study-companion-b85fd',
    storageBucket: 'als-study-companion-b85fd.firebasestorage.app',
  );
}
