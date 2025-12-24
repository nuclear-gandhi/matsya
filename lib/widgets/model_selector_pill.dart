import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import 'touchable_surface.dart';

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
        quantization != null ? '$modelName · $quantization' : modelName;

    return TouchableSurface(
      onTap: onTap,
      borderRadius: 24,
      backgroundColor: Colors.white.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
