import 'package:local_auth/local_auth.dart';

/// Wraps device authentication. Prompts biometrics if available; otherwise (or on
/// biometric failure) falls back to the device PIN/pattern/password — because
/// biometricOnly is false. We never store a PIN ourselves; the OS owns it.
class AuthLockService {
  final LocalAuthentication _auth;
  AuthLockService([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  /// True if the device can do any local auth (biometric or device credential).
  Future<bool> canAuthenticate() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Prompt the user. Returns true only on successful unlock.
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock AuthForge to view your codes',
        biometricOnly: false, // allow device PIN/password fallback
        persistAcrossBackgrounding: true, // survive backgrounding mid-prompt
      );
    } catch (_) {
      return false;
    }
  }
}
