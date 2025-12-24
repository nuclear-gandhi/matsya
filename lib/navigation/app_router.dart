import 'package:flutter/material.dart';
import 'package:matsya/models/model_manager.dart';
import '../screens/chat_screen.dart';
import '../screens/model_list_screen.dart';
import '../screens/model_download_screen.dart';
import '../screens/settings_screen.dart';

/// Route names for the application
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String modelList = '/model-list';
  static const String chat = '/chat';
  static const String modelDownload = '/model-download';
  static const String settings = '/settings';
}

/// Home screen that checks for downloaded models and navigates accordingly
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: ModelManager.getDownloadedModels(),
      builder: (context, snapshot) {
        // Show loading while checking
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If models exist, show chat screen with first model
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final firstModel = snapshot.data!.first;
          return ChatScreen(modelName: firstModel);
        }

        // Otherwise, show model list screen
        return const ModelListScreen();
      },
    );
  }
}

/// App router configuration
class AppRouter {
  AppRouter._();

  /// Generate routes for the application
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<HomeScreen>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.modelList:
        return MaterialPageRoute<ModelListScreen>(
          builder: (_) => const ModelListScreen(),
          settings: settings,
        );

      case AppRoutes.chat:
        final args = settings.arguments;
        if (args is String) {
          return MaterialPageRoute<ChatScreen>(
            builder: (_) => ChatScreen(modelName: args),
            settings: settings,
          );
        }
        // Fallback if no model name provided
        return MaterialPageRoute<ModelListScreen>(
          builder: (_) => const ModelListScreen(),
          settings: settings,
        );

      case AppRoutes.modelDownload:
        return MaterialPageRoute<ModelDownloadScreen>(
          builder: (_) => const ModelDownloadScreen(),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute<SettingsScreen>(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute<ModelListScreen>(
          builder: (_) => const ModelListScreen(),
          settings: settings,
        );
    }
  }

  /// Navigate to chat screen with model name
  static void navigateToChat(BuildContext context, String modelName) {
    Navigator.pushNamed(context, AppRoutes.chat, arguments: modelName);
  }

  /// Navigate to model list screen
  static void navigateToModelList(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.modelList);
  }

  /// Navigate to model download screen
  static Future<void> navigateToModelDownload(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.modelDownload);
  }

  /// Navigate to settings screen
  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  /// Navigate back
  static void navigateBack(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// Navigate back until a specific route
  static void navigateBackUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// Replace current route
  static Future<void> pushReplacementNamed(
    BuildContext context,
    String routeName, {
    dynamic arguments,
  }) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }
}
