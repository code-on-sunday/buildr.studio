import 'dart:async';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:buildr_studio/models/prompt_service_connection_status.dart';
import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:buildr_studio/services/prompt_service/prompt_service.dart';
import 'package:buildr_studio/utils/api_key_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class AnthropicPromptService implements PromptService {
  AnthropicPromptService({
    required ApiKeyManager apiKeyManager,
  }) : _apiKeyManager = apiKeyManager;

  final _logger = GetIt.I.get<Logger>();
  final ApiKeyManager _apiKeyManager;
  late AnthropicClient _client;
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
    final apiKey = await _apiKeyManager.getApiKey(AIService.anthropic.keyName!);
    if (apiKey == null) {
      _errorController.sink.add('Anthropic API Key is not set.');
      return;
    }

    _client = AnthropicClient(apiKey: apiKey);
    _connected = true;
    _connectionStatusController.sink
        .add(const PromptServiceConnectionStatus.connected());
  }

  @override
  void sendPrompt({
    required String prompt,
    String? deviceKey,
  }) async {
    try {
      if (!connected) {
        await connect();
      }
      final responseStream = _client.createMessageStream(
        request: CreateMessageRequest(
          model: const Model.model(Models.claude3Haiku20240307),
          maxTokens: 4000,
          messages: [
            Message(
              role: MessageRole.user,
              content: MessageContent.text(prompt),
            ),
          ],
        ),
      );

      await for (final res in responseStream) {
        res.map(
          messageStart: (e) {
            _logger.d(e.message.usage);
          },
          messageDelta: (e) {
            _logger.d(e.usage);
          },
          messageStop: (e) {},
          contentBlockStart: (e) {},
          contentBlockDelta: (e) {
            _responseController.sink.add(e.delta.text);
          },
          contentBlockStop: (e) {
            _endController.sink.add(null);
          },
          ping: (e) {},
        );
      }
    } catch (e) {
      _errorController.sink.add(e.toString());
    }
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

  @override
  void dispose() {
    _responseController.close();
    _errorController.close();
    _endController.close();
    _connectionStatusController.close();
  }
}
