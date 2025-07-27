// lib/core/locale_provider.dart
import 'package:flutter/material.dart';
import 'language_helper.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(String languageCode) {
    _locale = Locale(languageCode);
    LanguageHelper.setLocale(languageCode); // Save it persistently
    notifyListeners(); // Notify UI to rebuild
  }

  Future<void> loadSavedLocale() async {
    String? code = await LanguageHelper.getLocale();
    _locale = Locale(code ?? 'en');
    notifyListeners();
  }
}
