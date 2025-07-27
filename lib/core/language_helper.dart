import 'package:shared_preferences/shared_preferences.dart';

class LanguageHelper {
  static const _key = 'selected_language';
  static const languageOptions = [
    {'id': 'en', 'label': 'English'},
    {'id': 'hi', 'label': 'हिन्दी'},
    {'id': 'te', 'label': 'తెలుగు'},
    {'id': 'ml', 'label': 'മലയാളം'},
    {'id': 'kn', 'label': 'ಕನ್ನಡ'},
    {'id': 'ta', 'label': 'தமிழ்'},
  ];

  static Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
  }

  static Future<String> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? 'en'; // default to English
  }
}
