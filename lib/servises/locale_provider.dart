import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  String _lang = 'en';

  Locale get currentLocale => _currentLocale;
  String get lang => _lang;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return;
    _currentLocale = locale;
    _lang = locale.languageCode;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', _lang);
  }

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('lang') ?? 'en';
    _currentLocale =
        L10n.all.firstWhere((locale) => locale.languageCode == _lang);
    notifyListeners();
  }
}

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('uk'),
  ];

  static String getFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'uk':
        return '🇺🇦';
      default:
        return '🏳';
    }
  }
}
