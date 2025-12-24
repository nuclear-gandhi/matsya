import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphic_ui_kit/glassmorphic_ui_kit.dart';
import '../models/model_manager.dart';
import '../widgets/futuristic_button.dart';
import '../widgets/futuristic_card.dart';
import '../design/app_theme.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import '../navigation/app_router.dart';

class ModelListScreen extends StatefulWidget {
  const ModelListScreen({super.key});

  @override
  State<ModelListScreen> createState() => _ModelListScreenState();
}

class _ModelListScreenState extends State<ModelListScreen> {
  late Future<List<String>> _modelsFuture;

  @override
  void initState() {
    super.initState();
    _modelsFuture = ModelManager.getDownloadedModels();
  }

  void _refreshModels() {
    setState(() {
      _modelsFuture = ModelManager.getDownloadedModels();
    });
  }

  void _deleteModel(String modelName) {
    showDialog(
      context: context,
      builder: (context) => GlassDialog(
        blur: 15,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withAlpha(51),
            AppColors.surface.withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        title: Text(
          'Delete $modelName?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          GlassButton(
            onPressed: () => Navigator.pop(context),
            blur: 10,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          GlassButton(
            onPressed: () async {
              try {
                await ModelManager.deleteModel(modelName);
                Navigator.pop(context);
                _refreshModels();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$modelName deleted'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Error deleting model: $e');
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting model: $e'),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            blur: 10,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matsya - LLM Chat'), elevation: 0),
      body: FutureBuilder<List<String>>(
        future: _modelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('Error loading models: ${snapshot.error}');
            return Center(
              child: FuturisticCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error loading models',
                      style: AppTheme.h2.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: AppSpacing.spaceXS),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodySecondary,
                    ),
                  ],
                ),
              ),
            );
          }

          final models = snapshot.data ?? [];

          if (models.isEmpty) {
            return Center(
              child: FuturisticCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No models downloaded yet',
                      style: AppTheme.h2,
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    FuturisticButton(
                      label: 'Download a Model',
                      onPressed: () {
                        AppRouter.navigateToModelDownload(context)
                            .then((_) => _refreshModels());
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceMD),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: models.length,
                    itemBuilder: (context, index) {
                      final model = models[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceXS),
                        child: FuturisticCard(
                          child: ListTile(
                            title: Text(model),
                            subtitle: FutureBuilder<int>(
                              future: ModelManager.getModelSize(model),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final sizeInBytes = snapshot.data!;
                                  final sizeInMB = sizeInBytes / (1024 * 1024);
                                  // Display in GB if >= 1GB, otherwise MB
                                  if (sizeInMB >= 1024) {
                                    final sizeInGB = sizeInMB / 1024;
                                    return Text(
                                      '${sizeInGB.toStringAsFixed(2)} GB',
                                    );
                                  } else {
                                    return Text(
                                      '${sizeInMB.toStringAsFixed(2)} MB',
                                    );
                                  }
                                }
                                return const Text('Computing size...');
                              },
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem(
                                      child: const Text('Delete'),
                                      onTap: () => _deleteModel(model),
                                    ),
                                  ],
                            ),
                            onTap: () {
                              AppRouter.navigateToChat(context, model);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                FuturisticButton(
                  label: 'Download New Model',
                  onPressed: () {
                    AppRouter.navigateToModelDownload(context)
                        .then((_) => _refreshModels());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
