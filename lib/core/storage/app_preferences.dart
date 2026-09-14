import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dữ liệu cục bộ không nhạy cảm: yêu thích, đơn đã đánh giá, cơ sở dùng gần nhất.
@lazySingleton
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  List<String> getStringList(String key) =>
      _prefs.getStringList(key) ?? const [];

  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  int? getInt(String key) => _prefs.getInt(key);

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  List<Map<String, dynamic>> getJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) =>
      _prefs.setString(key, jsonEncode(value));

  Future<void> remove(String key) => _prefs.remove(key);
}
