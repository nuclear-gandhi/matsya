import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import 'model_selector_pill.dart';
import 'touchable_surface.dart';

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
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              // Menu icon on left
              if (onMenuTap != null) ...[
                TouchableSurface(
                  onTap: onMenuTap,
                  width: 44,
                  height: 44,
                  borderRadius: 22,
                  padding: EdgeInsets.zero,
                  child: const Center(
                    child: Icon(
                      Icons.format_list_bulleted,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
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
              if (onComposeTap != null) ...[
                const SizedBox(width: AppSpacing.xs),
                TouchableSurface(
                  onTap: onComposeTap,
                  width: 44,
                  height: 44,
                  borderRadius: 22,
                  padding: EdgeInsets.zero,
                  child: const Center(
                    child: Icon(
                      Icons.edit_note,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
