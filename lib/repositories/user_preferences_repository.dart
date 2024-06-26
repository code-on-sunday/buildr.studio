import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesRepository {
  UserPreferencesRepository({required SharedPreferences prefs})
      : _prefs = prefs;

  final SharedPreferences _prefs;

  static const _keyAiService = 'ai_service';
  static const _keyLastWorkingDir = 'last_working_dir';
  static const _keyAccountId = 'account_id';
  static const _keyHidePrimaryAlert = 'hide_primary_alert';
  static const _keyLastSelectedToolId = 'last_selected_tool_id';

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

  Future<void> clearLastWorkingDir() async {
    await _prefs.remove(_keyLastWorkingDir);
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

  Future<void> setHidePrimaryAlert(bool hide) async {
    await _prefs.setBool(_keyHidePrimaryAlert, hide);
  }

  bool getHidePrimaryAlert() {
    return _prefs.getBool(_keyHidePrimaryAlert) ?? false;
  }

  Future<void> setLastSelectedToolId(String? toolId) async {
    if (toolId == null) {
      await _prefs.remove(_keyLastSelectedToolId);
      return;
    }
    await _prefs.setString(_keyLastSelectedToolId, toolId);
  }

  String? getLastSelectedToolId() {
    return _prefs.getString(_keyLastSelectedToolId);
  }
}
