import 'package:authforge/src/core/constants/lock_constants.dart';
import 'package:authforge/src/core/di/injection.dart';
import 'package:authforge/src/core/theme/app_colors.dart';
import 'package:authforge/src/domain/domain.dart';
import 'package:flutter/material.dart';

/// Gates [child] behind device authentication. Locks on first launch and again
/// whenever the app returns from the background. While locked, only the lock UI
/// is shown; codes are never visible until the user unlocks.
class AppLock extends StatefulWidget {
  final Widget child;
  const AppLock({super.key, required this.child});

  @override
  State<AppLock> createState() => _AppLockState();
}

class _AppLockState extends State<AppLock> with WidgetsBindingObserver {
  final AuthLockService _lock = sl<AuthLockService>();
  bool _unlocked = false;
  bool _authing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-lock when the app leaves the foreground.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      setState(() => _unlocked = false);
    }
  }

  Future<void> _authenticate() async {
    if (_authing || _unlocked) return;
    setState(() => _authing = true);

    // If the device can't do local auth at all, don't lock the user out.
    final supported = await _lock.canAuthenticate();
    final ok = supported ? await _lock.authenticate() : true;

    if (!mounted) return;
    setState(() {
      _unlocked = ok;
      _authing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;
    return _LockView(authing: _authing, onUnlock: _authenticate);
  }
}

class _LockView extends StatelessWidget {
  final bool authing;
  final VoidCallback onUnlock;
  const _LockView({required this.authing, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 72,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            const Text(
              LockConstants.appName,
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              LockConstants.tagline,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),
            if (authing)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: onUnlock,
                icon: const Icon(Icons.fingerprint),
                label: const Text(LockConstants.unlockButton),
              ),
          ],
        ),
      ),
    );
  }
}
