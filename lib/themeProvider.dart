import 'package:flutter/material.dart';
import 'themes.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = darkTheme;
  bool _isLightMode = false;

  ThemeData get currentTheme => _currentTheme;
  bool get isLightMode => _isLightMode;

  void toggleTheme() {
    _isLightMode = !_isLightMode;
    _currentTheme = _isLightMode ? lightTheme : darkTheme;
    notifyListeners();
  }
}
