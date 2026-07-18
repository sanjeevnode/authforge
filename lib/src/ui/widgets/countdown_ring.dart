import 'package:authforge/src/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Circular countdown showing seconds left in the current 30s TOTP window.
/// Ring drains as time passes; turns to warning color in the last few seconds.
class CountdownRing extends StatelessWidget {
  final int secondsRemaining;
  final int period;
  const CountdownRing({
    super.key,
    required this.secondsRemaining,
    this.period = 30,
  });

  @override
  Widget build(BuildContext context) {
    final progress = secondsRemaining / period;
    final color = secondsRemaining <= 5 ? AppColors.warning : AppColors.accent;
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: AppColors.surfaceHigh,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            '$secondsRemaining',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
