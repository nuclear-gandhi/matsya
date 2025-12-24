import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphic_ui_kit/glassmorphic_ui_kit.dart';
import '../models/model_manager.dart';
import '../services/hugging_face_service.dart';
import '../widgets/futuristic_button.dart';
import '../widgets/futuristic_card.dart';
import '../design/app_theme.dart';
import '../design/colors.dart';
import '../design/spacing.dart';

class ModelDownloadScreen extends StatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  State<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<ModelDownloadScreen> {
  final List<Map<String, String>> _recommendedModels = [
    //unsloth/functiongemma-270m-it-GGUF
    //file: unctiongemma-270m-it-BF16.gguf
    {
      'name': 'FunctionGemma 270M IT',
      'description':
          'A compact Italian language model for efficient performance.',
      'size': '500 MB',
      'repoId': 'unsloth/functiongemma-270m-it-GGUF',
      'filename': 'functiongemma-270m-it-BF16.gguf',
    },

    //unsloth/gemma-3-270m-it-GGUF
    //gemma-3-270m-it-Q8_0.gguf
    {
      'name': 'Gemma 3 270M IT',
      'description':
          'An advanced Italian language model with improved capabilities.',
      'size': '600 MB',
      'repoId': 'unsloth/gemma-3-270m-it-GGUF',
      'filename': 'gemma-3-270m-it-Q8_0.gguf',
    },
    //TheBloke/phi-2-GGUF
    //phi-2.Q2_K.gguf
    {
      'name': 'Phi 2',
      'description': 'A versatile language model for various applications.',
      'size': '1.5 GB',
      'repoId': 'TheBloke/phi-2-GGUF',
      'filename': 'phi-2.Q2_K.gguf',
    },
    //telosnex/fllama
    //HuggingFaceTB_SmolLM3-3B-Q4_0.gguf
    {
      'name': 'SmolLM 3B',
      'description': 'A powerful 3-billion parameter language model.',
      'size': '4.5 GB',
      'repoId': 'telosnex/fllama',
      'filename': 'HuggingFaceTB_SmolLM3-3B-Q4_0.gguf',
    },
  ];

  late TextEditingController _repoController;
  late TextEditingController _filenameController;
  String? _downloadingModel;
  double _downloadProgress = 0;
  bool _isDownloading = false;
  DateTime? _lastProgressUpdate;
  static const Duration _progressThrottle = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _repoController = TextEditingController();
    _filenameController = TextEditingController();
  }

  @override
  void dispose() {
    _repoController.dispose();
    _filenameController.dispose();
    super.dispose();
  }

  Future<void> _downloadModel(
    String name,
    String repoId,
    String filename,
  ) async {
    if (_isDownloading) return;

    if (mounted) {
      setState(() {
        _isDownloading = true;
        _downloadingModel = name;
        _downloadProgress = 0;
      });
    }

    try {
      final modelPath = await ModelManager.getModelPath(filename);
      final exists = await ModelManager.modelExists(filename);

      if (exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name already exists'),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _downloadingModel = null;
          });
        }
        return;
      }

      await downloadModel(
        repoId,
        filename,
        modelPath,
        onProgress: (received, total) {
          // Throttle progress updates to avoid UI spam
          final now = DateTime.now();
          if (_lastProgressUpdate == null ||
              now.difference(_lastProgressUpdate!) >= _progressThrottle) {
            _lastProgressUpdate = now;
            if (mounted) {
              setState(() {
                _downloadProgress = total > 0 ? received / total : 0;
              });
            }
          }
        },
      );

      // Verify download completed successfully
      final downloadExists = await ModelManager.modelExists(filename);
      if (!downloadExists) {
        throw Exception('Download completed but file not found');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name downloaded successfully'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error downloading model: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading model: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadingModel = null;
          _downloadProgress = 0;
          _lastProgressUpdate = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download Models'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Models',
              style: AppTheme.h1,
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            ..._recommendedModels.map(
              (model) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceXS),
                child: FuturisticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model['name']!,
                        style: AppTheme.h2,
                      ),
                      const SizedBox(height: AppSpacing.spaceXXS),
                      Text(
                        'Size: ${model['size']}',
                        style: AppTheme.caption,
                      ),
                      const SizedBox(height: AppSpacing.spaceXS),
                      Text(model['description']!, style: AppTheme.body),
                      const SizedBox(height: AppSpacing.spaceMD),
                      if (_downloadingModel == model['name'])
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlassProgressIndicator(
                              value: _downloadProgress,
                              blur: 10,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.accent.withAlpha(200),
                                  AppColors.accent.withAlpha(150),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spaceXS),
                            Text(
                              '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                              style: AppTheme.bodySecondary,
                            ),
                          ],
                        )
                      else
                        FuturisticButton(
                          label: 'Download',
                          onPressed: _isDownloading
                              ? null
                              : () => _downloadModel(
                                    model['name']!,
                                    model['repoId']!,
                                    model['filename']!,
                                  ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXL),
            Text(
              'Custom Model',
              style: AppTheme.h1,
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            FuturisticCard(
              child: Column(
                children: [
                  GlassContainer(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    blur: 10,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.surface.withAlpha(51),
                        AppColors.surface.withAlpha(26),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: TextField(
                      controller: _repoController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Repository ID (e.g., user/model)',
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(AppSpacing.spaceSM),
                      ),
                      enabled: !_isDownloading,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceMD),
                  GlassContainer(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    blur: 10,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.surface.withAlpha(51),
                        AppColors.surface.withAlpha(26),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: TextField(
                      controller: _filenameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Filename (e.g., model.gguf)',
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(AppSpacing.spaceSM),
                      ),
                      enabled: !_isDownloading,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceMD),
                  if (_downloadingModel == 'custom')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassProgressIndicator(
                          value: _downloadProgress,
                          blur: 10,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent.withAlpha(200),
                              AppColors.accent.withAlpha(150),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spaceXS),
                        Text(
                          '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                          style: AppTheme.bodySecondary,
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),
                      ],
                    ),
                  FuturisticButton(
                    label: 'Download Custom Model',
                    onPressed: _isDownloading ||
                            _repoController.text.isEmpty ||
                            _filenameController.text.isEmpty
                        ? null
                        : () => _downloadModel(
                              'custom',
                              _repoController.text,
                              _filenameController.text,
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
