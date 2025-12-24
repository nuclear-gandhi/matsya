import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import 'model_selector_pill.dart';

/// Custom navigation bar widget
class AppNavigationBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final String? modelName;
  final String? quantization;
  final VoidCallback? onModelSelectorTap;
  final VoidCallback? onComposeTap;
  final String? title;

  const AppNavigationBar({
    super.key,
    this.onMenuTap,
    this.modelName,
    this.quantization,
    this.onModelSelectorTap,
    this.onComposeTap,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Menu icon on left
              if (onMenuTap != null)
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  onPressed: onMenuTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              // Title or Model selector in center
              Expanded(
                child:
                    title != null
                        ? Center(
                          child: Text(
                            title!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        : modelName != null
                        ? Center(
                          child: ModelSelectorPill(
                            modelName: modelName!,
                            quantization: quantization,
                            onTap: onModelSelectorTap,
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
              // Compose/new message icon on right
              if (onComposeTap != null)
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  onPressed: onComposeTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
