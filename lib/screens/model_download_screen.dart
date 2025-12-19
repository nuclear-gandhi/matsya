import 'package:flutter/material.dart';
import '../models/model_manager.dart';
import '../services/hugging_face_service.dart';
import '../widgets/futuristic_button.dart';
import '../widgets/futuristic_card.dart';

class ModelDownloadScreen extends StatefulWidget {
  const ModelDownloadScreen({Key? key}) : super(key: key);

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$name already exists')));
        }
        setState(() {
          _isDownloading = false;
          _downloadingModel = null;
        });
        return;
      }

      await downloadModel(
        repoId,
        filename,
        modelPath,
        onProgress: (received, total) {
          if (mounted) {
            setState(() {
              _downloadProgress = total > 0 ? received / total : 0;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading model: $e')));
      }
    } finally {
      if (!_isDownloading) {
        setState(() {
          _isDownloading = false;
          _downloadingModel = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download Models'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended Models',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._recommendedModels.map(
              (model) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: FuturisticCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model['name']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Size: ${model['size']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(model['description']!),
                      const SizedBox(height: 12),
                      if (_downloadingModel == model['name'])
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _downloadProgress,
                              minHeight: 8,
                              backgroundColor: Colors.grey[800],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.tealAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                            ),
                          ],
                        )
                      else
                        FuturisticButton(
                          label: 'Download',
                          onPressed:
                              _isDownloading
                                  ? () {}
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
            const SizedBox(height: 32),
            const Text(
              'Custom Model',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FuturisticCard(
              child: Column(
                children: [
                  TextField(
                    controller: _repoController,
                    decoration: InputDecoration(
                      hintText: 'Repository ID (e.g., user/model)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    enabled: !_isDownloading,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _filenameController,
                    decoration: InputDecoration(
                      hintText: 'Filename (e.g., model.gguf)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    enabled: !_isDownloading,
                  ),
                  const SizedBox(height: 12),
                  if (_downloadingModel == 'custom')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: _downloadProgress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.tealAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  FuturisticButton(
                    label: 'Download Custom Model',
                    onPressed:
                        _isDownloading ||
                                _repoController.text.isEmpty ||
                                _filenameController.text.isEmpty
                            ? () {}
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
