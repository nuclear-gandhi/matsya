import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fllama/fllama.dart';
import 'package:glassmorphic_ui_kit/glassmorphic_ui_kit.dart';
import '../models/model_manager.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/model_selector_dropdown.dart';
import '../design/app_theme.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import '../navigation/app_router.dart';

class ChatScreen extends StatefulWidget {
  final String modelName;

  const ChatScreen({super.key, required this.modelName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoading = false;
  String? _modelPath;
  bool _isModelLoading = true;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  final GlobalKey _modelPillKey = GlobalKey();
  String _currentModelName = '';
  String? _quantization;

  static const List<String> _thinkingMessages = [
    'Tangling with electrons...',
    'Calculating neural weights...',
    'Using electric brain...',
    'Processing quantum thoughts...',
    'Synapsing through circuits...',
    'Weaving digital neurons...',
  ];

  @override
  void initState() {
    super.initState();
    _currentModelName = widget.modelName;
    _extractQuantization();
    _loadModelPath();
  }

  void _extractQuantization() {
    // Extract quantization from model name if present (e.g., "model-4bit")
    final parts = _currentModelName.split('-');
    if (parts.length > 1) {
      final lastPart = parts.last.toLowerCase();
      if (lastPart.contains('bit')) {
        _quantization = lastPart;
      }
    }
  }

  void _loadModelPath([String? modelName]) async {
    final targetModelName = modelName ?? _currentModelName;
    try {
      // Set loading state
      if (mounted) {
        setState(() {
          _isModelLoading = true;
        });
      }

      // Check model type first
      final modelType = await ModelManager.getModelType(targetModelName);
      if (modelType == null) {
        throw Exception(
          'Model "$targetModelName" not found. Please ensure it is installed.',
        );
      }

      final path = await ModelManager.getModelPath(targetModelName);
      final exists = await ModelManager.modelExists(targetModelName);

      if (!exists) {
        throw Exception(
          'Model file not found: $targetModelName. Please re-download the model.',
        );
      }

      if (mounted) {
        setState(() {
          _modelPath = path;
          _isModelLoading = false;
        });
      }
      debugPrint('Model path loaded: $_modelPath');
    } catch (e) {
      debugPrint('Error loading model path: $e');
      if (mounted) {
        setState(() {
          _isModelLoading = false;
          _modelPath = null; // Ensure model path is null on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading model: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _sendQuery(String query) {
    if (query.isEmpty ||
        _isLoading ||
        _modelPath == null ||
        _modelPath!.isEmpty)
      return;

    final modelPath = _modelPath!; // Safe to use ! here since we checked above

    setState(() {
      _isLoading = true;
      _messages.add({'role': 'user', 'content': query});
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final request = OpenAiRequest(
        maxTokens: 256,
        messages: [
          Message(Role.system, 'You are a helpful chatbot.'),
          ..._messages.where((m) => m['role'] != null).map((m) {
            final role = m['role'] == 'user' ? Role.user : Role.assistant;
            return Message(role, m['content'] ?? '');
          }).toList(),
        ],
        numGpuLayers: 99,
        modelPath: modelPath,
        contextSize: 2048,
        temperature: 0.1,
        topP: 1.0,
        frequencyPenalty: 0.0,
        presencePenalty: 1.1,
        logger: (log) {
          debugPrint('[llama.cpp] $log');
        },
      );

      // Add placeholder for assistant response to show streaming
      final assistantMessageIndex = _messages.length;
      final randomThinkingMessage =
          _thinkingMessages[Random().nextInt(_thinkingMessages.length)];
      _messages.add({'role': 'assistant', 'content': randomThinkingMessage});

      String fullResponse = '';
      // Proper callback signature for fllamaChat: (response, openaiResponseJsonString, done)
      fllamaChat(request, (
        String response,
        String openaiResponseJsonString,
        bool done,
      ) {
        if (!mounted) return;

        fullResponse = response;

        // Update UI with streaming response
        setState(() {
          _messages[assistantMessageIndex]['content'] = fullResponse;
          if (done) {
            _isLoading = false;
          }
        });
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint('Error sending query: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showModelSelector() {
    ModelSelectorDropdown.show(
      context: context,
      currentModel: _currentModelName,
      onModelSelected: (modelName) {
        if (modelName != _currentModelName) {
          _switchModel(modelName);
        }
      },
      pillKey: _modelPillKey,
    );
  }

  void _switchModel(String newModelName) {
    if (newModelName != _currentModelName) {
      // Update current model name
      setState(() {
        _currentModelName = newModelName;
        _quantization = null; // Reset quantization before re-extracting
      });

      // Re-extract quantization for new model
      _extractQuantization();

      // Stop any ongoing requests
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }

      // Reload model path for the new model
      _loadModelPath(newModelName);
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            AppNavigationBar(
              onMenuTap: () {
                Scaffold.of(context).openDrawer();
              },
              modelName: _currentModelName,
              quantization: _quantization,
              onModelSelectorTap: _showModelSelector,
              onComposeTap: _clearChat,
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return GlassDrawer(
      blur: 15,
      opacity: 0.2,
      child: Column(
        children: [
          GlassContainer(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.zero,
            blur: 20,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Matsya',
                    style: AppTheme.h1.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.spaceXS),
                  Text('Offline LLM Chat', style: AppTheme.bodySecondary),
                ],
              ),
            ),
          ),
          GlassDrawerTile(
            leading: const Icon(
              Icons.model_training,
              color: AppColors.textPrimary,
            ),
            title: const Text(
              'Model List',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              AppRouter.navigateToModelList(context);
            },
          ),
          GlassDrawerTile(
            leading: const Icon(Icons.settings, color: AppColors.textPrimary),
            title: const Text(
              'Settings',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              AppRouter.navigateToSettings(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isModelLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_modelPath == null || _modelPath!.isEmpty) {
      return _buildErrorState();
    }

    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty ? _buildEmptyState() : _buildMessagesList(),
        ),
        _buildInputField(),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSpacing.spaceMD),
            Text(
              'Model not found',
              style: AppTheme.h2.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            const Text(
              'Please download the model first.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const SizedBox.shrink();
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: false,
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message['role'] == 'user';
        final content = message['content'] ?? '';

        return ChatMessageBubble(
          key: ValueKey('message_$index'),
          message: content,
          isUser: isUser,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceXS),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.spaceMD),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textSecondary),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spaceMD,
        AppSpacing.spaceSM,
        AppSpacing.spaceMD,
        AppSpacing.spaceLG,
      ),
      color: Colors.transparent,
      child: GlassContainer(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(24),
        blur: 10,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1C1C1E).withAlpha(255),
            const Color(0xFF1C1C1E).withAlpha(255),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSM),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    hintStyle: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  enabled: !_isLoading,
                  onSubmitted: _isLoading ? null : (value) => _sendQuery(value),
                ),
              ),
              if (!_isLoading)
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      final message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        _sendQuery(message);
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
