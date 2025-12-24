import 'package:flutter/material.dart';
import 'design/app_theme.dart';
import 'navigation/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matsya - Offline LLM Chat',
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
