# Product Requirements Document (PRD)

## Matsya - Offline LLM Chat Application

### 1. Product Overview

**Product Name:** Matsya  
**Version:** 1.0.0  
**Platform:** Flutter (iOS, Android, Web, Desktop)

Matsya is a Flutter-based mobile and desktop application that enables users to run Large Language Models (LLMs) completely offline on their devices. The app supports multiple model frameworks (Fllama and Flutter Gemma) and provides an intuitive chat interface for interacting with AI models without requiring internet connectivity.

### 2. Core Features

#### 2.1 Model Management

- **Model Discovery**: Browse and discover available models from Hugging Face
- **Model Download**: Download models directly from Hugging Face repositories
- **Model Storage**: Store downloaded models locally on device
- **Model List**: View all installed models (both Fllama and Gemma types)
- **Model Deletion**: Remove models to free up storage space
- **Model Information**: Display model size, type, and capabilities

#### 2.2 Chat Interface

- **Conversational UI**: Chat-based interface for interacting with models
- **Multi-Model Support**: Support for both Fllama (GGUF) and Flutter Gemma models
- **Message History**: Maintain conversation history during session
- **Real-time Responses**: Stream responses from models as they generate
- **Function Calling**: Support for function/tool calling capabilities (where supported by model)

#### 2.3 Model Frameworks

**Fllama Framework:**

- Supports GGUF format models (.gguf, .bin files)
- Models downloaded from Hugging Face
- Stored in application documents directory

**Flutter Gemma Framework:**

- Supports Gemma model family (Gemma 3, Gemma 3 Nano, etc.)
- Supports multimodal models (image input)
- Supports function calling
- Models managed through Flutter Gemma SDK

### 3. Technical Architecture

#### 3.1 Technology Stack

- **Framework**: Flutter 3.7.0+
- **Language**: Dart
- **Model Frameworks**:
  - `fllama` (Git dependency)
  - `flutter_gemma` (v0.11.13)
- **HTTP Client**: `http` (^1.1.0)
- **Storage**: `path_provider` (^2.0.0)
- **UI**: Material Design with custom futuristic theme

#### 3.2 Application Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── base_model.dart         # Base interfaces
│   ├── model.dart              # Model enum definitions
│   └── model_manager.dart      # Model storage/retrieval logic
├── screens/
│   ├── model_list_screen.dart  # Main screen - model list
│   ├── model_download_screen.dart # Model download interface
│   └── chat_screen.dart        # Chat interface
├── services/
│   └── hugging_face_service.dart # Hugging Face API integration
└── widgets/
    ├── futuristic_button.dart   # Custom button widget
    └── futuristic_card.dart     # Custom card widget
```

#### 3.3 Data Flow

1. **Model Discovery**: User browses recommended models or enters custom Hugging Face repo
2. **Model Download**: App downloads model file from Hugging Face to local storage
3. **Model Registration**: Model is registered in ModelManager (Fllama: file-based, Gemma: JSON registry)
4. **Model Loading**: When user starts chat, model is loaded into memory
5. **Inference**: User queries are sent to model, responses streamed back
6. **Model Cleanup**: Models can be deleted to free storage

### 4. User Stories

#### 4.1 Model Management

- **As a user**, I want to browse available models so I can choose the best one for my needs
- **As a user**, I want to download models so I can use them offline
- **As a user**, I want to see my installed models so I know what's available
- **As a user**, I want to delete models so I can free up storage space
- **As a user**, I want to see model sizes so I can manage my storage

#### 4.2 Chat Experience

- **As a user**, I want to chat with models so I can get AI assistance offline
- **As a user**, I want to see conversation history so I can reference previous messages
- **As a user**, I want real-time responses so I can see the model thinking
- **As a user**, I want to use function calling so I can extend model capabilities

### 5. Non-Functional Requirements

#### 5.1 Performance

- Model loading should complete within reasonable time (< 30 seconds for typical models)
- Chat responses should start streaming within 2-3 seconds
- UI should remain responsive during model operations

#### 5.2 Storage

- Models can range from 300MB to 15GB+
- App should handle storage constraints gracefully
- Provide clear storage usage information

#### 5.3 Security

- API tokens should be stored securely (not hardcoded)
- Model files should be validated after download
- User data (conversations) should be stored securely

#### 5.4 Usability

- Dark theme with futuristic aesthetic
- Clear error messages for users
- Progress indicators for long operations
- Intuitive navigation

### 6. Supported Models

#### 6.1 Gemma Models (Priority)

- Gemma 3 Nano E2B IT (3.1GB) - Multimodal, Function Calls
- Gemma 3 Nano E4B IT (6.5GB) - Multimodal, Function Calls
- Gemma 3 1B IT (0.5GB)
- Gemma 3 270M IT (0.3GB)

#### 6.2 Other Models

- DeepSeek R1 Distill Qwen 1.5B (1.7GB)
- Qwen 2.5 1.5B Instruct (1.6GB)
- TinyLlama 1.1B Chat (1.2GB)
- Hammer 2.1 0.5B (0.5GB)
- Llama 3.2 1B Instruct (1.1GB)
- Phi-4 Mini Instruct (3.9GB)

#### 6.3 Fllama Models (Downloadable)

- FunctionGemma 270M IT
- Gemma 2/3 variants
- Phi 2
- SmolLM 3B
- Qwen variants
- Llama variants


Design System:
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  /// =====================
  /// Colors (Dark Mode)
  /// =====================
  static const Color backgroundPrimary = Color(0xFF0B0B0D);
  static const Color backgroundSecondary = Color(0xFF121216);
  static const Color surface = Color(0xFF1E1E22);
  static const Color surfaceSubtle = Color(0xFF232327);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B8);
  static const Color textTertiary = Color(0xFF7D7D85);
  static const Color textDisabled = Color(0xFF5A5A60);

  static const Color accent = Color(0xFFE5E5EA);
  static const Color success = Color(0xFF30D158);
  static const Color error = Color(0xFFFF453A);

  /// =====================
  /// Spacing (8pt Grid)
  /// =====================
  static const double spaceXXS = 4;
  static const double spaceXS = 8;
  static const double spaceSM = 12;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;

  /// =====================
  /// Border Radius
  /// =====================
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 20;

  /// =====================
  /// Text Styles
  /// =====================
  static const String fontFamily = 'SF Pro';

  static const TextStyle h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    letterSpacing: -0.1,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    color: textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.2,
    color: textTertiary,
  );

  /// =====================
  /// ThemeData
  /// =====================
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundPrimary,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      background: backgroundPrimary,
      surface: surface,
      error: error,
    ),
    textTheme: const TextTheme(
      headlineLarge: h1,
      headlineMedium: h2,
      bodyLarge: body,
      bodyMedium: bodySecondary,
      labelSmall: caption,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundPrimary,
      elevation: 0,
      titleTextStyle: h1,
    ),
  );
}



