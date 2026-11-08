import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/network/api_response.dart';
import '../../../core/storage/app_preferences.dart';
import '../domain/entities/travel_theme.dart';

/// Sở thích du lịch của người dùng: lưu trên máy (cả khách chưa đăng nhập) và, với khách đã có hồ sơ,
/// đồng bộ lên BE để nhận gợi ý và thông báo khuyến mãi hợp sở thích.
@lazySingleton
class InterestStore {
  InterestStore(this._prefs, this._dio);

  static const _key = 'travel_interests';
  static const _askedKey = 'travel_interests_asked';

  final AppPreferences _prefs;
  final Dio _dio;

  List<TravelTheme> get interests =>
      _prefs.getStringList(_key).map(TravelTheme.tryParse).whereType<TravelTheme>().toList();

  /// Đã hỏi sở thích (chọn xong hoặc bỏ qua) — màn chọn sở thích không hiện lại.
  bool get asked => _prefs.getInt(_askedKey) == 1;

  Future<void> save(List<TravelTheme> interests, {bool sync = true}) async {
    await _prefs.setStringList(_key, [for (final theme in interests) theme.value]);
    await _prefs.setInt(_askedKey, 1);
    if (sync) await push();
  }

  Future<void> skip() => _prefs.setInt(_askedKey, 1);

  /// Gửi sở thích trên máy lên hồ sơ khách; lỗi (chưa đăng nhập, chưa có hồ sơ, mất mạng) thì bỏ qua.
  Future<void> push() async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/customers/me/interests',
        data: {'interests': [for (final theme in interests) theme.value]},
      );
      ApiResponse.fromJson(response.data ?? const {}).ensureSuccess();
    } catch (_) {}
  }
}
