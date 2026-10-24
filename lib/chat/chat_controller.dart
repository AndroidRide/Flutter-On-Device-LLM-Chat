import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_on_device_llm/constants.dart';

class ChatController extends ChangeNotifier {
  int? downloadPercent;
  bool _alive = true;

  InferenceModel? _model;
  InferenceChat? _chat;
  bool initializing = true;

  final messages = <Message>[];

  bool isGenerating = false;

  final draft = ValueNotifier<String>('');

  StreamSubscription<ModelResponse>? _responseSubscription;

  bool clearing = false;

  bool get canClear =>
      _chat != null && !clearing && !isGenerating && messages.isNotEmpty;

  Future<void> init() async {
    try {
      await FlutterGemma.installModel(
        modelType: ModelType.gemma4,
        fileType: ModelFileType.litertlm,
      ).fromNetwork(gemmaUrl, foreground: true).withProgress((percent) {
        downloadPercent = percent;
        _notify();
      }).install();

      _model = await FlutterGemma.getActiveModel(
        maxTokens: 4096,
        supportImage: true,
        supportAudio: true,
      );
      _chat = await _model!.createChat(
        supportAudio: true,
        supportImage: true,
        temperature: 1.0,
        maxOutputTokens: 4096,
        topK: 64,
        topP: 0.95,
        modelType: ModelType.gemma4,
        systemInstruction:
            'You are a helpful on-device assistant. Be concise and friendly.',
      );

      initializing = false;
    } catch (e) {
      print('Error installing model: $e');
    }

    _notify();
  }

  void _notify() {
    if (_alive) notifyListeners();
  }

  Future<void> send(Message userMessage) async {
    final chat = _chat;
    if (chat == null) return;

    await _responseSubscription?.cancel();

    messages.add(userMessage);
    isGenerating = true;
    _notify();

    try {
      await chat.addQuery(userMessage);

      _responseSubscription = chat.generateChatResponseAsync().listen(
        (response) {
          if (response is TextResponse) {
            draft.value += response.token;
          }
        },
        onDone: () {
          _finishGeneration();
        },
      );
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> clear() async {
    if (clearing || isGenerating) return;
    clearing = true;
    try {
      await _responseSubscription?.cancel();
      _responseSubscription = null;
      await _chat?.close();
      _chat = await _model!.createChat(
        supportImage: true,
        supportAudio: true,
        temperature: 1.0,
        topK: 64,
        topP: 0.95,
        modelType: ModelType.gemma4,
        systemInstruction:
            'You are a helpful on-device assistant. Be concise and friendly.',
      );
      messages.clear();
      draft.value = '';
    } catch (e) {
      print(e);
    } finally {
      clearing = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _alive = false;
    _chat?.close();
    _responseSubscription?.cancel();
    super.dispose();
  }

  void _finishGeneration() {
    if (draft.value.isNotEmpty) {
      messages.add(Message(text: draft.value, isUser: false));
    }

    draft.value = '';
    isGenerating = false;
    _notify();
  }
}
