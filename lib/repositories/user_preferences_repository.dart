import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesRepository {
  UserPreferencesRepository({required SharedPreferences prefs})
      : _prefs = prefs;

  final SharedPreferences _prefs;

  static const _keyAiService = 'ai_service';

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
}
