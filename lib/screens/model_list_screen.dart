import 'package:flutter/material.dart';
import '../models/model_manager.dart';
import '../widgets/futuristic_button.dart';
import '../widgets/futuristic_card.dart';
import 'chat_screen.dart';
import 'model_download_screen.dart';

class ModelListScreen extends StatefulWidget {
  const ModelListScreen({Key? key}) : super(key: key);

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
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black,
            title: Text('Delete $modelName?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await ModelManager.deleteModel(modelName);
                  Navigator.pop(context);
                  _refreshModels();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$modelName deleted')));
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final models = snapshot.data ?? [];

          if (models.isEmpty) {
            return Center(
              child: FuturisticCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No models downloaded yet',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    FuturisticButton(
                      label: 'Download a Model',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ModelDownloadScreen(),
                          ),
                        ).then((_) => _refreshModels());
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: models.length,
                    itemBuilder: (context, index) {
                      final model = models[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: FuturisticCard(
                          child: ListTile(
                            title: Text(model),
                            subtitle: FutureBuilder<int>(
                              future: ModelManager.getModelSize(model),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final sizeInMB =
                                      snapshot.data! / (1024 * 1024);
                                  return Text(
                                    '${sizeInMB.toStringAsFixed(2)} MB',
                                  );
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatScreen(modelName: model),
                                ),
                              );
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ModelDownloadScreen(),
                      ),
                    ).then((_) => _refreshModels());
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
