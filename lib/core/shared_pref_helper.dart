import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String _keyUsername = 'username';
  static const String _keyPhoneNumber = 'phone_number';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLanguageCode = 'language_code';

  /// Save user details and login status
  static Future<void> saveUserDetails({
    required String username,
    required String phoneNumber,
    bool isLoggedIn = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyPhoneNumber, phoneNumber);
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  /// Get username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// Get phone number
  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhoneNumber);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Clear all user data
  static Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyPhoneNumber);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
  static Future<void> saveSelectedLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguageCode, langCode);
  }

  static Future<String?> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguageCode);
  }
  static Future<void> saveLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
  }

}
