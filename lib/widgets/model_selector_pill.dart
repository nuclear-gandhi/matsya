import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import '../design/app_theme.dart';

/// Model selector pill widget
class ModelSelectorPill extends StatelessWidget {
  final String modelName;
  final String? quantization;
  final VoidCallback? onTap;

  const ModelSelectorPill({
    super.key,
    required this.modelName,
    this.quantization,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayText =
        quantization != null ? '$modelName • $quantization' : modelName;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                displayText,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
