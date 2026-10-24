import 'package:flutter/material.dart';
import 'package:flutter_gemma/core/message.dart';
import 'package:flutter_on_device_llm/chat/chat_composer.dart';
import 'package:flutter_on_device_llm/chat/chat_controller.dart';
import 'package:flutter_on_device_llm/constants.dart';
import 'package:flutter_on_device_llm/widgets/chat_download_view.dart';
import 'package:flutter_on_device_llm/widgets/chat_empty_state.dart';
import 'package:flutter_on_device_llm/widgets/chat_input_bar.dart';
import 'package:flutter_on_device_llm/widgets/message_bubble.dart';
import 'package:flutter_on_device_llm/widgets/type_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = ChatController();
  final _composer = ChatComposer();

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  void _send() {
    final message = _composer.takeMessage();

    if (message != null) {
      _controller.send(message);
    }
  }

  Future<void> _confirmClear() async {
    if (!_controller.canClear) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear conversation'),
          content: const Text(
            'This removes all messages and starts a new chat session.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(gemmaDisplayName),
            centerTitle: true,
            actions: [
              if (!_controller.initializing && !_controller.isGenerating)
                IconButton(
                  onPressed: () {
                    _confirmClear();
                  },
                  icon: Icon(Icons.delete),
                ),
            ],
          ),
          body: _controller.initializing
              ? ChatDownloadView(percent: _controller.downloadPercent)
              : Column(
                  children: [
                    Expanded(
                      child:
                          _controller.messages.isEmpty &&
                              !_controller.isGenerating
                          ? ChatEmptyState(
                              onSuggestion: (text) {
                                _controller.send(
                                  Message.text(text: text, isUser: true),
                                );
                              },
                            )
                          : ListView.builder(
                              reverse: true,
                              padding: const EdgeInsets.all(12),
                              itemCount:
                                  _controller.messages.length +
                                  (_controller.isGenerating ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (_controller.isGenerating && index == 0) {
                                  return ValueListenableBuilder(
                                    valueListenable: _controller.draft,
                                    builder: (context, draft, _) {
                                      if (draft.isEmpty) {
                                        return const TypingIndicatorBubble();
                                      }

                                      return MessageBubble(
                                        message: Message(text: draft),
                                      );
                                    },
                                  );
                                }

                                final msgIndex = _controller.isGenerating
                                    ? index - 1
                                    : index;

                                final message =
                                    _controller.messages[_controller
                                            .messages
                                            .length -
                                        1 -
                                        msgIndex];
                                return MessageBubble(message: message);
                              },
                            ),
                    ),
                    ChatInputBar(
                      composer: _composer,
                      onSend: _send,
                      enabled: !_controller.isGenerating,
                    ),
                  ],
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _composer.dispose();
    super.dispose();
  }
}
