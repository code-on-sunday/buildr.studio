import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:buildr_studio/utils/api_key_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class ApiKeyState extends ChangeNotifier {
  ApiKeyState(
      {required AIService aiService, required ApiKeyManager apiKeyManager})
      : _aiService = aiService,
        _apiKeyManager = apiKeyManager {
    _loadApiKey();
  }

  final _logger = GetIt.I.get<Logger>();

  final ApiKeyManager _apiKeyManager;
  final AIService _aiService;
  String? _apiKey = '';

  String? get apiKey => _apiKey;
  String? get keyName => _aiService.keyName;

  Future<void> _loadApiKey() async {
    if (keyName == null) {
      return;
    }
    try {
      _apiKey = await _getApiKey();
    } catch (e) {
      _logger.e('Error loading API key: $e');
      _apiKey = null;
    }
    notifyListeners();
  }

  Future<String?> _getApiKey() async {
    final key = await _apiKeyManager.getApiKey(keyName!);
    if (key == null || key.isEmpty) {
      return null;
    }
    return key;
  }

  Future<void> saveApiKey(String apiKey) async {
    try {
      await _apiKeyManager.saveApiKey(keyName!, apiKey);
      _apiKey = apiKey;
      notifyListeners();
      // Set the API key in the environment variables or use it as needed
      _logger.d('API key saved: $apiKey');
    } catch (e) {
      // Log the error or display it to the UI
      _logger.e('Error saving API key: $e');
    }
  }
}
