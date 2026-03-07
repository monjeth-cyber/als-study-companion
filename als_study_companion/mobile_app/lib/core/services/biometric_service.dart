import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Service that wraps [LocalAuthentication] to provide fingerprint / Face ID
/// authentication capabilities.
///
/// Usage:
///   final ok = await biometricService.authenticate(reason: 'Confirm identity');
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // -------------------------------------------------------------------------
  // Capability checks
  // -------------------------------------------------------------------------

  /// Returns [true] if the device hardware supports biometric authentication
  /// AND the user has at least one biometric enrolled.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;

      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Returns the list of enrolled [BiometricType]s (e.g. fingerprint, face).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Returns a human-readable label for the strongest available biometric
  /// (e.g. "Face ID", "Fingerprint"). Falls back to "Biometrics".
  Future<String> getBiometricLabel() async {
    final types = await getAvailableBiometrics();
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Fingerprint';
    if (types.contains(BiometricType.strong)) return 'Biometrics';
    return 'Biometrics';
  }

  // -------------------------------------------------------------------------
  // Authentication
  // -------------------------------------------------------------------------

  /// Prompts the user for biometric authentication.
  ///
  /// [reason] is shown in the OS prompt.
  /// Returns [true] on success, [false] on failure or user cancellation.
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Cancels any in-progress authentication prompt.
  Future<void> cancelAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } on PlatformException {
      // ignore — nothing to cancel
    }
  }
}
