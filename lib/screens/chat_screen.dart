import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fllama/fllama.dart';
import '../models/model_manager.dart';
import '../widgets/futuristic_card.dart';
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

  void _loadModelPath() async {
    try {
      // Check model type first
      final modelType = await ModelManager.getModelType(widget.modelName);
      if (modelType == null) {
        throw Exception(
          'Model "${widget.modelName}" not found. Please ensure it is installed.',
        );
      }

      final path = await ModelManager.getModelPath(widget.modelName);
      final exists = await ModelManager.modelExists(widget.modelName);

      if (!exists) {
        throw Exception(
          'Model file not found: ${widget.modelName}. Please re-download the model.',
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
      _messages.add({'role': 'assistant', 'content': ''});

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
      // Navigate to new chat screen with selected model
      AppRouter.navigateToChat(context, newModelName);
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
    return Drawer(
      backgroundColor: AppColors.backgroundPrimary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.backgroundSecondary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          ListTile(
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
          ListTile(
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
        if (_isLoading) _buildLoadingIndicator(),
        _buildInputField(),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: FuturisticCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Model not found',
              style: AppTheme.h2.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            const Text(
              'Please download the model first.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FuturisticCard(
        child: const Text(
          'Start a conversation!\nAsk me anything.',
          textAlign: TextAlign.center,
        ),
      ),
    );
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

        // Don't show empty assistant messages (streaming placeholder)
        if (!isUser &&
            content.isEmpty &&
            index == _messages.length - 1 &&
            _isLoading) {
          return const SizedBox.shrink();
        }

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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: TextField(
        controller: _messageController,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Message',
          hintStyle: const TextStyle(color: AppColors.textTertiary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            borderSide: const BorderSide(
              color: AppColors.inputFocused,
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMD,
            vertical: AppSpacing.spaceSM,
          ),
          suffixIconConstraints: const BoxConstraints(
            maxHeight: 42,
            maxWidth: 48,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.spaceXXS,
              AppSpacing.spaceXXS,
              AppSpacing.spaceXS,
              AppSpacing.spaceXXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_upward,
                color: AppColors.backgroundPrimary,
                size: 20,
              ),
              onPressed:
                  _isLoading
                      ? null
                      : () {
                        final message = _messageController.text.trim();
                        if (message.isNotEmpty) {
                          _sendQuery(message);
                        }
                      },
              padding: const EdgeInsets.all(AppSpacing.spaceXXS),
              // right margin to align with the input field
              constraints: const BoxConstraints(maxHeight: 42, maxWidth: 42),
            ),
          ),
        ),
        enabled: !_isLoading,
        onSubmitted: _isLoading ? null : (value) => _sendQuery(value),
      ),
    );
  }
}
