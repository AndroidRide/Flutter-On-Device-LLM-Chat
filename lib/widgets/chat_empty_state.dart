import 'package:flutter/material.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key, required this.onSuggestion});

  final ValueChanged<String> onSuggestion;

  static const suggestions = [
    'Tell me a story in 100 words',
    'What is Flutter?',
    'Explain relativity',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('On-device LLM Chat', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                children: [
                   TextSpan(text: 'Chat with text ', style: theme.textTheme.bodyLarge),
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: Colors.blue,
                    ),
                  ),
                  TextSpan(text: ', photo ',style: theme.textTheme.bodyLarge),
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.photo_outlined,
                      size: 18,
                      color: Colors.green,
                    ),
                  ),
                   TextSpan(text: ', or voice ', style: theme.textTheme.bodyLarge),
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.mic_none,
                      size: 18,
                      color: Colors.orange,
                    ),
                  ),
                  const TextSpan(text: '\nNothing leaves the phone.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final text in suggestions)
                  ActionChip(
                    label: Text(text),
                    onPressed: () => onSuggestion(text),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
