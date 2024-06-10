import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyManager {
  static const _apiKeyKey = 'anthropic_api_key';

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }
}
