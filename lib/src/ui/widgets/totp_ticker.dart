import 'dart:async';

import 'package:flutter/foundation.dart';

/// A single app-wide 1-second ticker. Every [OtpCard] listens to THIS instead of
/// owning its own Timer, so all cards recompute their code + countdown at the
/// exact same instant. Without a shared tick, each card's timer starts at a
/// different sub-second phase (whenever that card mounted) and their countdowns
/// visibly disagree by up to a second even though the TOTP math is identical.
///
/// The value is just a monotonically increasing tick count — cards don't use it
/// directly, they use it as a "recompute now" signal.
class TotpTicker extends ValueNotifier<int> {
  Timer? _timer;

  TotpTicker() : super(0) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => value++);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// One shared instance for the whole app. Created lazily on first use and lives
/// for the app's lifetime (a single 1s timer is negligible).
final totpTicker = TotpTicker();
