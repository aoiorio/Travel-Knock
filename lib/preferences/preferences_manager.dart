import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  factory PreferencesManager() {
    return _incessance;
  }
  PreferencesManager._internal();
  static late final SharedPreferences _preferences;
  static final PreferencesManager _incessance = PreferencesManager._internal();
  Future<void> set(SharedPreferences preferences) async =>
      _preferences = preferences;
  Future<bool> get isLogin async {
    return _preferences.getBool('isLogin') ?? false;
  }
  Future<void> setIsLogin({
    required bool isLogin,
  }) async {
    await _preferences.setBool('isLogin', isLogin);
  }
}