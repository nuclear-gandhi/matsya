import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ModelManager {
  static const String modelsDir = 'matsya_models';
  static const String gemmaRegistryFile = 'installed_gemma_models.json';

  static Future<Directory> getModelsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${appDir.path}/$modelsDir');
    if (!modelDir.existsSync()) {
      modelDir.createSync(recursive: true);
    }
    return modelDir;
  }

  static Future<File> _getGemmaRegistryFile() async {
    final dir = await getModelsDirectory();
    return File('${dir.path}/$gemmaRegistryFile');
  }

  /// Get the type of a model ('gemma', 'fllama', or null if not found)
  static Future<String?> getModelType(String modelName) async {
    // Check if it's a Gemma model by checking registry
    final gemmaModels = await getInstalledGemmaModels();
    if (gemmaModels.contains(modelName)) {
      return 'gemma';
    }

    // Check if it's a Fllama model by file extension
    final exists = await modelExists(modelName);
    if (exists) {
      if (modelName.endsWith('.gguf') || modelName.endsWith('.bin')) {
        return 'fllama';
      }
      // Check if it's a Gemma file type
      if (modelName.endsWith('.task') || modelName.endsWith('.litertlm')) {
        return 'gemma';
      }
    }

    return null;
  }

  /// Get list of installed Gemma models from registry
  static Future<List<String>> getInstalledGemmaModels() async {
    try {
      final registryFile = await _getGemmaRegistryFile();
      if (!registryFile.existsSync()) {
        return [];
      }

      final content = await registryFile.readAsString();
      if (content.isEmpty) {
        return [];
      }

      final json = jsonDecode(content) as Map<String, dynamic>;
      final models = json['models'] as List<dynamic>?;
      return models?.map((m) => m.toString()).toList() ?? [];
    } catch (e) {
      debugPrint('Error reading Gemma registry: $e');
      // If file is corrupted, recreate it
      final registryFile = await _getGemmaRegistryFile();
      if (registryFile.existsSync()) {
        try {
          await registryFile.delete();
        } catch (_) {
          // Ignore deletion errors
        }
      }
      return [];
    }
  }

  /// Add a Gemma model to the registry
  static Future<void> addGemmaModel(String displayName) async {
    try {
      final models = await getInstalledGemmaModels();
      if (!models.contains(displayName)) {
        models.add(displayName);
        await _saveGemmaRegistry(models);
      }
    } catch (e) {
      debugPrint('Error adding Gemma model to registry: $e');
    }
  }

  /// Remove a Gemma model from the registry
  static Future<void> removeGemmaModel(String displayName) async {
    try {
      final models = await getInstalledGemmaModels();
      models.remove(displayName);
      await _saveGemmaRegistry(models);
    } catch (e) {
      debugPrint('Error removing Gemma model from registry: $e');
    }
  }

  /// Save the Gemma registry to file
  static Future<void> _saveGemmaRegistry(List<String> models) async {
    try {
      final registryFile = await _getGemmaRegistryFile();
      final json = jsonEncode({'models': models});
      await registryFile.writeAsString(json);
    } catch (e) {
      debugPrint('Error saving Gemma registry: $e');
    }
  }

  /// Get list of Fllama models (only .gguf and .bin files)
  static Future<List<String>> getFllamaModels() async {
    final dir = await getModelsDirectory();
    final files = dir.listSync();
    return files
        .where((f) => f is File && (f.path.endsWith('.gguf') || f.path.endsWith('.bin')))
        .map((f) => (f as File).path.split('/').last)
        .toList();
  }

  static Future<List<String>> getDownloadedModels() async {
    final dir = await getModelsDirectory();
    final files = dir.listSync();
    return files
        .where((f) => f is File && (f.path.endsWith('.gguf') || f.path.endsWith('.bin') || f.path.endsWith('.task') || f.path.endsWith('.litertlm')))
        .map((f) => (f as File).path.split('/').last)
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
    final type = await getModelType(modelName);
    final path = await getModelPath(modelName);
    final file = File(path);
    
    if (file.existsSync()) {
      await file.delete();
    }
    
    // Remove from Gemma registry if it's a Gemma model
    if (type == 'gemma') {
      await removeGemmaModel(modelName);
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
