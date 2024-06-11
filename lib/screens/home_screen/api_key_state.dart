import 'package:buildr_studio/utils/api_key_manager.dart';
import 'package:flutter/material.dart';

class ApiKeyState extends ChangeNotifier {
  ApiKeyState({required ApiKeyManager apiKeyManager})
      : _apiKeyManager = apiKeyManager {
    _loadApiKey();
  }

  final ApiKeyManager _apiKeyManager;
  String? _apiKey = '';

  String? get apiKey => _apiKey;

  Future<void> _loadApiKey() async {
    try {
      _apiKey = await _getApiKey();
    } catch (e) {
      _apiKey = null;
    }
    notifyListeners();
  }

  Future<String?> _getApiKey() async {
    final key = await _apiKeyManager.getApiKey();
    if (key == null || key.isEmpty) {
      return null;
    }
    return key;
  }

  Future<void> saveApiKey(String apiKey) async {
    try {
      await _apiKeyManager.saveApiKey(apiKey);
      _apiKey = apiKey;
      notifyListeners();
      // Set the API key in the environment variables or use it as needed
      print('API key saved: $apiKey');
    } catch (e) {
      // Log the error or display it to the UI
      print('Error saving API key: $e');
    }
  }
}
