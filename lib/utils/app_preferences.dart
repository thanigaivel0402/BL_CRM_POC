import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static SharedPreferences? _prefs;
  static const String isLoggedInKey = 'IS_LOGGED_IN';

  /// Initialize SharedPreferences once (call in main or splash)
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save login state
  static Future<void> setLoggedIn(bool value) async {
    if (_prefs == null) await init();
    await _prefs!.setBool(isLoggedInKey, value);
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    if (_prefs == null) return false;
    return _prefs!.getBool(isLoggedInKey) ?? false;
  }

  /// Optional: clear all saved prefs (for logout)
  static Future<void> clear() async {
    if (_prefs == null) await init();
    await _prefs!.clear();
  }
}