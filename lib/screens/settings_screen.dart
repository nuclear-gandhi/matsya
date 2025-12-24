import 'package:flutter/material.dart';
import 'package:glassmorphic_ui_kit/glassmorphic_ui_kit.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import '../design/app_theme.dart';
import '../services/config_service.dart';

/// Settings screen for configuring app settings
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isLoading = false;
  bool _tokenVisible = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    setState(() => _isLoading = true);
    final token = await ConfigService.getHuggingFaceToken();
    setState(() {
      _tokenController.text = token ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveToken() async {
    await ConfigService.setHuggingFaceToken(_tokenController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hugging Face token saved'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _deleteToken() async {
    await ConfigService.deleteHuggingFaceToken();
    setState(() {
      _tokenController.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hugging Face token deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hugging Face Configuration',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Enter your Hugging Face API token to download models. Get your token from huggingface.co/settings/tokens',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                      controller: _tokenController,
                      obscureText: !_tokenVisible,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Hugging Face Token',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        hintText: 'hf_...',
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _tokenVisible ? Icons.visibility : Icons.visibility_off,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _tokenVisible = !_tokenVisible;
                            });
                          },
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveToken,
                          child: const Text('Save Token'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ElevatedButton(
                        onPressed: _deleteToken,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
