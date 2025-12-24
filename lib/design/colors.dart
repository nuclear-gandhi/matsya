import 'package:flutter/material.dart';

/// Color palette for dark theme - exact PRD specification
class AppColors {
  AppColors._();

  /// =====================
  /// Colors (Dark Mode)
  /// =====================
  static const Color backgroundPrimary = Color(0xFF000000);
  static const Color backgroundSecondary = Color(0xFF121216);
  static const Color surface = Color(0xFF1E1E22);
  static const Color surfaceSubtle = Color(0xFF232327);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B8);
  static const Color textTertiary = Color(0xFF7D7D85);
  static const Color textDisabled = Color(0xFF5A5A60);

  static const Color accent = Color(0xFFE5E5EA);
  static const Color success = Color(0xFF30D158);
  static const Color error = Color(0xFFFF453A);

  // Legacy colors for backward compatibility
  static const Color background = backgroundPrimary;
  static const Color surfaceLight = surfaceSubtle;
  static const Color surfaceLighter = Color(0xFF2A2A2F);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color info = Color(0xFF64D2FF);
  static const Color border = Color(0xFF2A2A2F);
  static const Color divider = Color(0xFF2A2A2F);
  static const Color inputBackground = surface;
  static const Color inputBorder = Color(0xFF2A2A2F);
  static const Color inputFocused = accent;
  static const Color userMessageBackground = surface;
  static const Color assistantMessageBackground = backgroundSecondary;
}
