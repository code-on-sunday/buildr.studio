import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyManager {
  ApiKeyManager({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  Future<String?> getApiKey(String keyName) async {
    return _prefs.getString(keyName);
  }

  Future<void> saveApiKey(String keyName, String apiKey) async {
    await _prefs.setString(keyName, apiKey);
  }
}
