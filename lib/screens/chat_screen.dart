import 'package:flutter/material.dart';
import 'package:fllama/fllama.dart';
import '../models/model_manager.dart';
import '../widgets/futuristic_button.dart';
import '../widgets/futuristic_card.dart';

class ChatScreen extends StatefulWidget {
  final String modelName;

  const ChatScreen({Key? key, required this.modelName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoading = false;
  late String _modelPath;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadModelPath();
  }

  void _loadModelPath() async {
    try {
      final path = await ModelManager.getModelPath(widget.modelName);
      setState(() {
        _modelPath = path;
      });
      print('Model path loaded: $_modelPath');
    } catch (e) {
      print('Error loading model path: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading model: $e')));
      }
    }
  }

  void _sendQuery(String query) {
    if (query.isEmpty || _isLoading || _modelPath.isEmpty) return;

    setState(() {
      _isLoading = true;
      _messages.add({'role': 'user', 'content': query});
      _messageController.clear();
    });

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
        modelPath: _modelPath,
        contextSize: 2048,
        temperature: 0.1,
        topP: 1.0,
        frequencyPenalty: 0.0,
        presencePenalty: 1.1,
        logger: (log) {
          print('[llama.cpp] $log');
        },
      );

      String fullResponse = '';
      // Proper callback signature for fllamaChat: (response, openaiResponseJsonString, done)
      fllamaChat(request, (
        String response,
        String openaiResponseJsonString,
        bool done,
      ) {
        fullResponse = response;
        // Check if inference is done
        if (done) {
          setState(() {
            _messages.add({'role': 'assistant', 'content': fullResponse});
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      print('Error sending query: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat - ${widget.modelName}'), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child:
                _messages.isEmpty
                    ? Center(
                      child: FuturisticCard(
                        child: const Text(
                          'Start a conversation!\nAsk me anything.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUser = message['role'] == 'user';
                        return Align(
                          alignment:
                              isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isUser
                                        ? Colors.tealAccent
                                        : Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isUser
                                          ? Colors.tealAccent
                                          : Colors.tealAccent.withOpacity(0.5),
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                message['content'] ?? '',
                                style: TextStyle(
                                  color: isUser ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask me something...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.tealAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.tealAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.tealAccent,
                          width: 2,
                        ),
                      ),
                    ),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                FuturisticButton(
                  label: 'Send',
                  onPressed:
                      _isLoading
                          ? () {}
                          : () => _sendQuery(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
