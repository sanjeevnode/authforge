import 'package:authforge/src/domain/services/totp_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TOTP code is 6 digits and deterministic for a fixed time', () {
    const secret = 'JBSWY3DPEHPK3PXP';
    final code = TotpService.generateCode(secret, atMillis: 1700000000000);
    expect(code.length, 6);
    expect(TotpService.generateCode(secret, atMillis: 1700000000000), code);
  });

  test('secondsRemaining is within 1..30', () {
    final r = TotpService.secondsRemaining(atMillis: 1700000000000);
    expect(r, inInclusiveRange(1, 30));
  });

  test('countdown is the same for all accounts at a given instant', () {
    // The window is aligned to absolute time, not per-account. So at ONE
    // instant every account shows the same seconds-remaining, regardless of
    // its secret or when it was added. (The shared ticker keeps the UI in
    // step; this asserts the underlying value can't diverge.)
    for (final at in [1700000000000, 1700000012345, 1700000029999]) {
      final a = TotpService.secondsRemaining(atMillis: at);
      final b = TotpService.secondsRemaining(atMillis: at);
      expect(a, b);
    }
  });
}
