import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:glassmorphic_ui_kit/glassmorphic_ui_kit.dart';
import '../design/colors.dart';
import '../design/app_theme.dart';

/// Touchable surface container with glassmorphic effect
class TouchableSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;

  const TouchableSurface({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = AppTheme.radiusLG,
    this.blur = 15,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // For accent colors, use a more solid background
    final isAccentColor = backgroundColor == AppColors.accent;

    Widget container;
    if (isAccentColor) {
      // Solid accent color for buttons like send
      container = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      );
    } else {
      // Glass effect for other surfaces
      container = GlassContainer(
        width: width,
        height: height,
        borderRadius: BorderRadius.circular(borderRadius),
        blur: blur,
        gradient: LinearGradient(
          colors: [
            backgroundColor!.withAlpha(99),
            backgroundColor!.withAlpha(99),
          ],
        ),

        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      );
    }

    if (onTap == null) {
      return Container(margin: margin, child: container);
    }

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: container,
        ),
      ),
    );
  }
}
