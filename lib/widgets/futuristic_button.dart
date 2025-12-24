import 'package:flutter/material.dart';
import 'package:glassmorphic_ui_kit/glassmorphic_ui_kit.dart';
import '../design/app_theme.dart';
import '../design/colors.dart';
import '../design/spacing.dart';

class FuturisticButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const FuturisticButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      onPressed: onPressed,
      blur: 15,
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      gradient: LinearGradient(
        colors: [
          AppColors.surface.withAlpha(51),
          AppColors.surface.withAlpha(26),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Container(
        height: AppSpacing.spaceLG,
        width: 200,
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTheme.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
