import 'package:flutter/material.dart';
import 'package:flutter_on_device_llm/chat/chat_composer.dart';
import 'package:flutter_on_device_llm/widgets/attachment_chip.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.composer,
    required this.onSend,
    required this.enabled,
  });

  final ChatComposer composer;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: composer,
      builder: (context, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Column(
              children: [
                if (composer.imageBytes != null || composer.audioBytes != null)
                  AttachmentChip(
                    imageBytes: composer.imageBytes,
                    audioLabel: composer.audioBytes != null
                        ? 'Audio ${composer.duration.inSeconds}s'
                        : null,
                    onClear: () {
                      composer.clearAttachment();
                    },
                  ),
                if (composer.recording)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.fiber_manual_record,
                          color: Colors.red,
                          size: 12,
                        ),
                        const SizedBox(width: 8),
                        Text('Recording ${composer.duration.inSeconds}s'),
                      ],
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed:
                          (enabled &&
                              !composer.recording &&
                              composer.audioBytes == null)
                          ? () => composer.pickImage(context)
                          : null,
                      icon: Icon(Icons.attach_file),
                    ),
                    Expanded(
                      child: TextField(
                        enabled: enabled && composer.audioBytes == null,
                        readOnly: composer.recording,
                        controller: composer.textController,
                        onSubmitted: (_) => onSend(),
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            onPressed:
                                (enabled &&
                                    composer.imageBytes == null &&
                                    composer.audioBytes == null)
                                ? () => composer.toggleRecording(context)
                                : null,
                            icon: Icon(
                              composer.recording ? Icons.stop : Icons.mic_none,
                            ),
                            color: composer.recording
                                ? Colors.red
                                : composer.audioBytes != null
                                ? theme.colorScheme.primary
                                : null,
                            disabledColor: theme.colorScheme.onSurface
                                .withValues(alpha: 0.38),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filled(
                      onPressed: enabled && !composer.recording ? onSend : null,
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
