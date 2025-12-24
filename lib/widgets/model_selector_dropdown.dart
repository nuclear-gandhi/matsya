import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import '../design/app_theme.dart';
import '../models/model_manager.dart';

/// Model selector dropdown widget that appears centered below the pill
class ModelSelectorDropdown extends StatelessWidget {
  final String currentModel;
  final Function(String) onModelSelected;
  final GlobalKey? pillKey;

  const ModelSelectorDropdown({
    super.key,
    required this.currentModel,
    required this.onModelSelected,
    this.pillKey,
  });

  /// Show the dropdown centered below the model selector pill
  static void show({
    required BuildContext context,
    required String currentModel,
    required Function(String) onModelSelected,
    GlobalKey? pillKey,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ModelSelectorDropdown(
          currentModel: currentModel,
          onModelSelected: onModelSelected,
          pillKey: pillKey,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: FutureBuilder<List<String>>(
          future: ModelManager.getDownloadedModels(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(AppSpacing.spaceLG),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AppSpacing.spaceLG),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                ),
                child: Center(
                  child: Text(
                    'No models available',
                    style: AppTheme.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }

            final models = snapshot.data!;
            final maxHeight = MediaQuery.of(context).size.height * 0.4;

            return Container(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // List of models
                    ...models.map(
                      (model) => _buildModelItem(
                        context,
                        model,
                        model == currentModel,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModelItem(
    BuildContext context,
    String modelName,
    bool isSelected,
  ) {
    return FutureBuilder<String?>(
      future: ModelManager.getModelType(modelName),
      builder: (context, snapshot) {
        final modelType = snapshot.data ?? 'fllama';
        final icon = _getModelIcon(modelType);

        return InkWell(
          onTap: () {
            Navigator.of(context).pop();
            onModelSelected(modelName);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceMD,
              vertical: AppSpacing.spaceMD,
            ),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.accent.withOpacity(0.2)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      isSelected ? AppColors.accent : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.spaceMD),
                Expanded(
                  child: Text(
                    modelName,
                    style: TextStyle(
                      color:
                          isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check, color: AppColors.accent, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getModelIcon(String modelType) {
    switch (modelType) {
      case 'gemma':
        return Icons.auto_awesome;
      case 'fllama':
        return Icons.memory;
      default:
        return Icons.psychology;
    }
  }
}
