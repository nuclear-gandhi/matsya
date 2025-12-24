import 'package:flutter/material.dart';
import 'package:glassmorphic_ui_kit/glassmorphic_ui_kit.dart';
import '../design/app_theme.dart';
import '../design/spacing.dart';

class FuturisticCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const FuturisticCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.spaceMD),
    this.margin = const EdgeInsets.all(AppSpacing.spaceXS),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: GlassContainer(
        height: 100, // Minimum height, will expand with content
        width: double.infinity,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        blur: 10,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
