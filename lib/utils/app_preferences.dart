import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
 static SharedPreferences? _sharedPreferences;
  static Future<SharedPreferences> getInstance() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }
  static const String isLoggedInKey = 'IS_LOGGED_IN';
  Future<void> setLoggedIn(bool value) async {
    await _sharedPreferences?.setBool(isLoggedInKey, value);
  }
  bool isLoggedIn() {
    return _sharedPreferences?.getBool(isLoggedInKey) ?? false;
  }
}