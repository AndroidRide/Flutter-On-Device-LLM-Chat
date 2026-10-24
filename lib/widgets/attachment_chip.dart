import 'dart:typed_data';

import 'package:flutter/material.dart';

class AttachmentChip extends StatelessWidget {
  const AttachmentChip({this.onClear, this.imageBytes, this.audioLabel});

  final VoidCallback? onClear;
  final Uint8List? imageBytes;
  final String? audioLabel;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InputChip(
          avatar: imageBytes != null
              ? CircleAvatar(backgroundImage: MemoryImage(imageBytes!))
              : const Icon(Icons.audiotrack, size: 18,),
          label: Text(audioLabel ?? 'Photo attached'),
          onDeleted: onClear,
        ),
      ),
    );
  }
}
