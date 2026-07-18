import 'package:flutter/material.dart';

/// AuthForge palette — 60-30-10 rule.
/// 60% deep indigo (surfaces), 30% violet (interactive), 10% mint (accent/success).
class AppColors {
  AppColors._();

  // 60% — dominant background/surface family
  static const Color background = Color(0xFF1E1B36); // slightly darker than surface
  static const Color surface = Color(0xFF2E2B4E); // #2E2B4E
  static const Color surfaceHigh = Color(0xFF3A3660); // raised cards

  // 30% — primary / interactive
  static const Color primary = Color(0xFFAA7DE4); // #AA7DE4
  static const Color primaryDim = Color(0xFF8A63C0);

  // 10% — accent / success / countdown
  static const Color accent = Color(0xFF52F9AB); // #52F9AB

  // Semantic
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFB454);

  // Text
  static const Color textPrimary = Color(0xFFF5F3FF);
  static const Color textSecondary = Color(0xFFB8B2D9);
  static const Color textMuted = Color(0xFF7C769E);
}
