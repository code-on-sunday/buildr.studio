import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyManager {
  ApiKeyManager({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;
  static const _apiKeyKey = 'anthropic_api_key';

  Future<String?> getApiKey() async {
    return _prefs.getString(_apiKeyKey);
  }

  Future<void> saveApiKey(String apiKey) async {
    await _prefs.setString(_apiKeyKey, apiKey);
  }
}
