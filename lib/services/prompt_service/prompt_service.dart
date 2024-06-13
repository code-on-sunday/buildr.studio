import 'dart:async';

import 'package:buildr_studio/models/prompt_service_connection_status.dart';

export 'buildr_studio_prompt_service.dart';

abstract class PromptService {
  void connect();
  void sendPrompt(String prompt);
  void dispose();
  bool get connected;
  Stream<String> get responseStream;
  Stream<String> get errorStream;
  Stream<void> get endStream;
  Stream<PromptServiceConnectionStatus> get connectionStatusStream;
}
