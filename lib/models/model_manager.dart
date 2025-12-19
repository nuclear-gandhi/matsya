import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ModelManager {
  static const String modelsDir = 'matsya_models';

  static Future<Directory> getModelsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${appDir.path}/$modelsDir');
    if (!modelDir.existsSync()) {
      modelDir.createSync(recursive: true);
    }
    return modelDir;
  }

  static Future<List<String>> getDownloadedModels() async {
    final dir = await getModelsDirectory();
    final files = dir.listSync();
    return files
        .where((f) => f.path.endsWith('.gguf') || f.path.endsWith('.bin'))
        .map((f) => f.path.split('/').last)
        .toList();
  }

  static Future<String> getModelPath(String modelName) async {
    final dir = await getModelsDirectory();
    return '${dir.path}/$modelName';
  }

  static Future<bool> modelExists(String modelName) async {
    final path = await getModelPath(modelName);
    return File(path).existsSync();
  }

  static Future<void> deleteModel(String modelName) async {
    final path = await getModelPath(modelName);
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  static Future<int> getModelSize(String modelName) async {
    final path = await getModelPath(modelName);
    final file = File(path);
    if (file.existsSync()) {
      return await file.length();
    }
    return 0;
  }
}
