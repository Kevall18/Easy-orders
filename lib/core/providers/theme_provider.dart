import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  late Box _box;
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  ThemeProvider() {
    _initHive();
  }
  
  Future<void> _initHive() async {
    _box = Hive.box('settings');
    _loadThemeMode();
  }
  
  void _loadThemeMode() {
    final savedMode = _box.get(_themeKey, defaultValue: 'system');
    switch (savedMode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _box.put(_themeKey, mode.name);
    notifyListeners();
  }
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  void toggleTheme() {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(newMode);
  }
}
