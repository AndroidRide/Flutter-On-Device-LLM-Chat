import 'package:flutter/material.dart';
import 'package:flutter_gemma/core/api/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:flutter_on_device_llm/constants.dart';
import 'package:flutter_on_device_llm/screens/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterGemma.initialize(
    inferenceEngines: [LiteRtLmEngine()]
  );
  runApp(const OnDeviceLLMApp());
}

class OnDeviceLLMApp extends StatelessWidget {
  const OnDeviceLLMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: gemmaDisplayName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B2351),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}
