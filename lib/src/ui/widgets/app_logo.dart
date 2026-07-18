import 'package:authforge/src/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The app's logo badge, matching the Android launcher icon: the foreground
/// mark centered on the surface (#2E2B4E) background, rounded. Use this in-app
/// (AppBar, lock screen) so the branding matches the home-screen icon.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    // Android adaptive icons clip to a rounded shape ~22% radius; mirror that.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface, // == adaptive_icon_background in pubspec
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      clipBehavior: Clip.antiAlias,
      // The foreground is drawn with the same ~66% safe-zone inset the launcher uses.
      child: Padding(
        padding: EdgeInsets.all(size * 0.17),
        child: Image.asset(
          'assets/images/logo_foreground.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
