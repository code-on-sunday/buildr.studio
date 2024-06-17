import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseThemeModeState extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ChooseThemeModeState({
    required SharedPreferences prefs,
  }) : _prefs = prefs {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final int? themeModeIndex = _prefs.getInt(_themeModeKey);
    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }
}
