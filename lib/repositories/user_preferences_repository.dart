import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesRepository {
  UserPreferencesRepository({required SharedPreferences prefs})
      : _prefs = prefs;

  final SharedPreferences _prefs;

  static const _keyAiService = 'ai_service';
  static const _keyLastWorkingDir = 'last_working_dir';
  static const _keyAccountId = 'account_id';

  Future<void> setAiService(AIService aiService) async {
    await _prefs.setString(_keyAiService, aiService.name);
  }

  AIService getAiService() {
    final aiServiceName = _prefs.getString(_keyAiService);
    return AIService.values.firstWhere(
      (element) => element.name == aiServiceName,
      orElse: () => AIService.buildrStudio,
    );
  }

  Future<void> setLastWorkingDir(String path) async {
    await _prefs.setString(_keyLastWorkingDir, path);
  }

  String? getLastWorkingDir() {
    return _prefs.getString(_keyLastWorkingDir);
  }

  Future<void> setAccountId(String accountId) async {
    await _prefs.setString(_keyAccountId, accountId);
  }

  String? getAccountId() {
    return _prefs.getString(_keyAccountId);
  }
}
