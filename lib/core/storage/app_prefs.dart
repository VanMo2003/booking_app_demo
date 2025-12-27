import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _kBaseUrl = 'baseUrl';
  static const _kToken = 'token';

  static Future<String> getBaseUrl() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kBaseUrl) ?? 'http://localhost:8080/booking-app/api/v1';
  }

  static Future<void> setBaseUrl(String v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kBaseUrl, v);
  }

  static Future<String> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken) ?? '';
  }

  static Future<void> setToken(String v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, v);
  }
}
