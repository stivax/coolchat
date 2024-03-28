import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themes.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = darkTheme;
  bool _isLightMode = false;
  bool _isThemeChange = true;
  bool _adaptiveTheme = true;
  Timer? _themeTimer;

  ThemeProvider() {
    _loadTheme();
    _scheduleThemeCheck();
  }

  ThemeData get currentTheme => _currentTheme;
  bool get isLightMode => _isLightMode;
  bool get isThemeChange => _isThemeChange;
  bool get adaptiveTheme => _adaptiveTheme;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _adaptiveTheme = prefs.getBool('adaptiveTheme') ?? true;
    _updateTheme();
  }

  Future<void> _updateTheme() async {
    if (_adaptiveTheme) {
      final hour = DateTime.now().hour;
      _isLightMode = hour >= 6 && hour < 21;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _isLightMode = prefs.getBool('isLightMode') ?? false;
    }
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

  Future<void> setAdaptiveTheme() async {
    _adaptiveTheme = !_adaptiveTheme;
    _updateTheme();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adaptiveTheme', _adaptiveTheme);
  }

  void _scheduleThemeCheck() {
    _themeTimer?.cancel();
    _isThemeChange = false;
    _themeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTheme();
    });
  }

  @override
  void dispose() {
    _themeTimer?.cancel();
    super.dispose();
  }
}
