import 'dart:async';

import 'package:buildr_studio/models/prompt_service_connection_status.dart';
import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:buildr_studio/services/prompt_service/prompt_service.dart';
import 'package:buildr_studio/utils/api_key_manager.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';

class GoogleGeminiPromptService extends PromptService {
  GoogleGeminiPromptService({required ApiKeyManager apiKeyManager})
      : _apiKeyManager = apiKeyManager;

  final _logger = Logger();
  final ApiKeyManager _apiKeyManager;
  late GenerativeModel _googleGenerativeAI;

  final _responseController = StreamController<String>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _endController = StreamController<void>.broadcast();
  final _connectionStatusController =
      StreamController<PromptServiceConnectionStatus>.broadcast();

  bool _connected = false;

  @override
  bool get connected => _connected;

  @override
  Future<void> connect() async {
    final apiKey = await _apiKeyManager.getApiKey(AIService.google.keyName!);
    if (apiKey == null) {
      _errorController.sink.add('Google API Key is not set.');
      return;
    }
    _googleGenerativeAI = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high)
        ]);
    _connectionStatusController.sink
        .add(const PromptServiceConnectionStatus.connected());
    _connected = true;
  }

  @override
  void sendPrompt(String prompt) async {
    try {
      if (!connected) {
        await connect();
      }
      final response =
          _googleGenerativeAI.generateContentStream([Content.text(prompt)]);
      await for (final chunk in response) {
        _responseController.sink.add(chunk.text ?? '');
      }
      _endController.sink.add(null);
    } catch (e, stack) {
      _logger.e('Failed to send prompt to Google Gemini Prompt Service',
          error: e, stackTrace: stack);
      _errorController.sink.add('Failed to generate text: $e');
    }
  }

  @override
  void dispose() {
    _responseController.close();
    _errorController.close();
    _endController.close();
    _connectionStatusController.close();
  }

  @override
  Stream<String> get responseStream => _responseController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Stream<void> get endStream => _endController.stream;

  @override
  Stream<PromptServiceConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;
}
