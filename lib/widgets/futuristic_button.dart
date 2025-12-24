import 'package:flutter/material.dart';
import 'package:glassmorphic_ui_kit/glassmorphic_ui_kit.dart';
import '../design/app_theme.dart';
import '../design/spacing.dart';

class FuturisticButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const FuturisticButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassContainer(
        height: AppSpacing.spaceLG,
        width: 200,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        blur: 15,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
