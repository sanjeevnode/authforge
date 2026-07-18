import 'package:flutter_test/flutter_test.dart';

import 'package:authforge/src/domain/services/totp_service.dart';

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
}
