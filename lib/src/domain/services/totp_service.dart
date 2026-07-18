import 'package:otp/otp.dart';

/// All TOTP math lives here — the UI never computes codes directly (plan rule).
/// This mirrors the server's pyotp logic so codes match exactly (RFC 6238).
class TotpService {
  static const int _digits = 6;
  static const int _periodSeconds = 30;

  /// The current 6-digit code for [secret] (base32), zero-padded to 6 chars.
  /// [atMillis] lets tests pin a specific moment; defaults to now.
  static String generateCode(String secret, {int? atMillis}) {
    final ms = atMillis ?? DateTime.now().millisecondsSinceEpoch;
    return OTP.generateTOTPCodeString(
      secret,
      ms,
      length: _digits,
      interval: _periodSeconds,
      algorithm: Algorithm.SHA1, // RFC 6238 / Google Authenticator default
      isGoogle: true,
    );
  }

  /// Seconds remaining in the current 30s window (for the countdown ring).
  static int secondsRemaining({int? atMillis}) {
    final ms = atMillis ?? DateTime.now().millisecondsSinceEpoch;
    final secondsIntoWindow = (ms ~/ 1000) % _periodSeconds;
    return _periodSeconds - secondsIntoWindow;
  }
}
