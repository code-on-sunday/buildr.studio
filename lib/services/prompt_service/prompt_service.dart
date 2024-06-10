import 'dart:async';

export 'buildr_studio_prompt_service.dart';

abstract class PromptService {
  void connect();
  void sendPrompt(String prompt);
  Stream<String> get responseStream;
  Stream<String> get errorStream;
  Stream<void> get endStream;
}
