// Base interfaces for model management

import 'package:flutter_gemma/flutter_gemma.dart';

abstract class InferenceModelInterface {
  String get filename;
  String get displayName;
  String get size;
  String get licenseUrl;
  bool get needsAuth;
  bool get localModel;
  PreferredBackend get preferredBackend;
  ModelType get modelType;
  double get temperature;
  int get topK;
  double get topP;
  bool get supportImage;
  int get maxTokens;
  int? get maxNumImages;
  bool get supportsFunctionCalls;
  String get url;
  String get name;
  bool get isEmbeddingModel;
  bool get supportsThinking;
}
