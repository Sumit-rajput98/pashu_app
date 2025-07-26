import 'package:shared_preferences/shared_preferences.dart';

class LanguageHelper {
  static const _key = 'selected_language';

  static Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
  }

  static Future<String> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? 'en'; // default to English
  }
}
