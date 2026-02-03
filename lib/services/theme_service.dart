import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._internal();

  ThemeService._internal();

  static const _kModeKey = 'theme_mode';
  static const _kSeedKey = 'seed_color';

  ThemeMode _mode = ThemeMode.system;
  Color _seedColor = Colors.deepPurple;

  ThemeMode get themeMode => _mode;
  Color get seedColor => _seedColor;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_kModeKey);
    if (mode != null) {
      _mode = switch (mode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    }
    final colorVal = prefs.getInt(_kSeedKey);
    if (colorVal != null) {
      _seedColor = Color(colorVal);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    _mode = m;
    final prefs = await SharedPreferences.getInstance();
    final s = switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await prefs.setString(_kModeKey, s);
    notifyListeners();
  }

  Future<void> toggleDarkLight() async {
    await setThemeMode(_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setSeedColor(Color c) async {
    _seedColor = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSeedKey, c.toARGB32());
    notifyListeners();
  }
}
