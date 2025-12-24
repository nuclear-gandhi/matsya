/// Spacing system for consistent layout - exact PRD specification
class AppSpacing {
  AppSpacing._();

  /// =====================
  /// Spacing (8pt Grid)
  /// =====================
  static const double spaceXXS = 4;
  static const double spaceXS = 8;
  static const double spaceSM = 12;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;

  // Legacy spacing for backward compatibility
  static const double xs = spaceXXS;
  static const double sm = spaceXS;
  static const double md = spaceMD;
  static const double lg = spaceLG;
  static const double xl = spaceXL;
  static const double xxl = 48.0;
}
