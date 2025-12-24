import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme - exact PRD specification
class AppTheme {
  AppTheme._();

  /// =====================
  /// Colors (Dark Mode)
  /// =====================
  static const Color backgroundPrimary = Color(0xFF0B0B0D);
  static const Color backgroundSecondary = Color(0xFF121216);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B8);
  static const Color textTertiary = Color(0xFF7D7D85);
  static const Color textDisabled = Color(0xFF5A5A60);

  static const Color accent = Color(0xFFE5E5EA);
  static const Color success = Color(0xFF30D158);
  static const Color error = Color(0xFFFF453A);

  /// =====================
  /// Spacing (8pt Grid)
  /// =====================
  static const double spaceXXS = 4;
  static const double spaceXS = 8;
  static const double spaceSM = 12;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;

  /// =====================
  /// Border Radius
  /// =====================
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 20;

  /// =====================
  /// Text Styles
  /// =====================
  static const String fontFamily =
      'Inter'; // Inter font for modern mobile UI // San Francisco font

  static TextStyle get h1 => GoogleFonts.roboto(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static TextStyle get h2 => GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    letterSpacing: -0.1,
    color: textPrimary,
  );

  static TextStyle get body => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static TextStyle get message => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static TextStyle get bodySecondary => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: textSecondary,
  );

  static TextStyle get caption => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.2,
    color: textTertiary,
  );

  /// =====================
  /// ThemeData
  /// =====================
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundPrimary,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      background: backgroundPrimary,
      surface: surface,
      error: error,
    ),
    textTheme: TextTheme(
      headlineLarge: h1,
      headlineMedium: h2,
      bodyLarge: body,
      bodyMedium: bodySecondary,
      labelSmall: caption,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundPrimary,
      elevation: 0,
      titleTextStyle: h1,
    ),
  );
}
