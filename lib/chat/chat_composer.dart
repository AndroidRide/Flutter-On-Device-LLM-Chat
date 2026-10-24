import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gemma/core/message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class ChatComposer extends ChangeNotifier {
  final textController = TextEditingController();

  final _picker = ImagePicker();
  Uint8List? imageBytes;

  final _recorder = AudioRecorder();
  Uint8List? audioBytes;

  bool recording = false;
  Duration duration = Duration.zero;
  Timer? _timer;

  static const _maxRecording = Duration(seconds: 60);

  Future<void> toggleRecording(BuildContext context) async {
    if (recording) {
      await stopRecording(context);
    } else {
      await startRecording(context);
    }
  }

  Future<void> startRecording(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Microphone permission required')),
      );
      return;
    }

    _timer?.cancel();
    _timer = null;
    duration = Duration.zero;
    audioBytes = null;

    recording = true;
    notifyListeners();

    final dir = await getTemporaryDirectory();
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: '${dir.path}/chat_audio.wav',
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      duration += const Duration(seconds: 1);
      notifyListeners();
      if (duration >= _maxRecording) {
        stopRecording(context);
      }
    });
  }

  Future<void> stopRecording(BuildContext context) async {
    _timer?.cancel();
    _timer = null;

    try {
      final path = await _recorder.stop();
      Uint8List? bytes;
      if (path != null) {
        final file = File(path);
        bytes = await file.readAsBytes();
        if (await file.exists()) await file.delete();
      }

      recording = false;
      audioBytes = bytes;
      notifyListeners();
    } catch (e) {
      recording = false;
      notifyListeners();
      final ctx = context;
      if (ctx != null && ctx.mounted) {
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(SnackBar(content: Text('Failed to save recording: $e')));
      }
    }
  }

  Future<void> pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_outlined),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Camera permission required')),
          );
          return;
        }
      }

      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null) return;
      imageBytes = await file.readAsBytes();
      notifyListeners();
    } catch (e) {
      print('Error requesting permission: $e');
    }
  }

  Message? takeMessage() {
    final text = textController.text.trim();

    if (text.isEmpty && imageBytes == null && audioBytes == null) return null;

    final Message message;

    if (audioBytes != null) {
      message = Message.withAudio(
        text: text,
        audioBytes: audioBytes!,
        isUser: true,
      );
    } else if (imageBytes != null) {
      message = Message(text: text, imageBytes: imageBytes, isUser: true);
    } else {
      message = Message(text: text, isUser: true);
    }

    textController.clear();
    clearAttachment();
    return message;
  }

  void clearAttachment() {
    imageBytes = null;
    audioBytes = null;
    duration = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
