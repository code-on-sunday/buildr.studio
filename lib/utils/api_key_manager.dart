import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyManager {
  static const _apiKeyKey = 'api_key';

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }
    static Future<bool?> getBot() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("bot");
  }

  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

    static Future<void> saveApiBot(bool apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("bot", apiKey);
  }
}
