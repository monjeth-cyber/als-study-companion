import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely stores and retrieves the credentials used for biometric auto-fill.
///
/// Backed by the OS keychain (iOS) / EncryptedSharedPreferences (Android).
/// Credentials are only written here after a successful biometric
/// authentication during the setup flow — they are NEVER stored in plain text
/// or in an unprotected location.
class SecureCredentialStorage {
  static const _kEmail = 'biometric_af_email';
  static const _kPassword = 'biometric_af_password';
  static const _kEnabled = 'biometric_af_enabled';

  final FlutterSecureStorage _storage;

  SecureCredentialStorage()
    : _storage = const FlutterSecureStorage(
        // Android: use hardware-backed EncryptedSharedPreferences
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        // iOS: store in the default Keychain accessible when device is
        // unlocked — this is the most secure option for user credentials.
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  // -------------------------------------------------------------------------
  // Write
  // -------------------------------------------------------------------------

  /// Persists [email] and [password] and marks biometric auto-fill as enabled.
  ///
  /// Must only be called AFTER the user has successfully authenticated with
  /// their biometric in the setup flow.
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await Future.wait([
      _storage.write(key: _kEmail, value: email),
      _storage.write(key: _kPassword, value: password),
      _storage.write(key: _kEnabled, value: 'true'),
    ]);
  }

  // -------------------------------------------------------------------------
  // Read
  // -------------------------------------------------------------------------

  /// Returns the saved credentials as a named record, or [null] if none are
  /// stored or if biometric auto-fill has been disabled.
  Future<({String email, String password})?> getCredentials() async {
    final enabled = await isEnabled();
    if (!enabled) return null;

    final email = await _storage.read(key: _kEmail);
    final password = await _storage.read(key: _kPassword);

    if (email == null || email.isEmpty) return null;
    if (password == null || password.isEmpty) return null;

    return (email: email, password: password);
  }

  /// Returns [true] when biometric auto-fill has been set up and is enabled.
  Future<bool> isEnabled() async {
    final val = await _storage.read(key: _kEnabled);
    return val == 'true';
  }

  // -------------------------------------------------------------------------
  // Clear
  // -------------------------------------------------------------------------

  /// Removes all stored credentials and disables biometric auto-fill.
  Future<void> clearCredentials() async {
    await Future.wait([
      _storage.delete(key: _kEmail),
      _storage.delete(key: _kPassword),
      _storage.delete(key: _kEnabled),
    ]);
  }
}
