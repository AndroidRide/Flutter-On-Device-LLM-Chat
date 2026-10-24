import 'package:flutter/material.dart';

class ChatDownloadView extends StatelessWidget {
  const ChatDownloadView({super.key, required this.percent});

  final int? percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = percent == null ? null : percent! / 100;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Gemma 4',
              style: theme.textTheme.titleLarge!.copyWith(fontSize: 30),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: value, minHeight: 6),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Downloading', style: theme.textTheme.bodyMedium),
                const Spacer(),
                Text(
                  percent == null ? '' : '$percent%',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
