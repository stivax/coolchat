import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themes.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = darkTheme;
  bool _isLightMode = false;
  bool _isThemeChange = true;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get currentTheme => _currentTheme;
  bool get isLightMode => _isLightMode;
  bool get isThemeChange => _isThemeChange;

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLightMode = prefs.getBool('isLightMode') ?? false;
    _currentTheme = _isLightMode ? lightTheme : darkTheme;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isLightMode = !_isLightMode;
    _currentTheme = _isLightMode ? lightTheme : darkTheme;
    _isThemeChange = false;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLightMode', _isLightMode);
  }
}
