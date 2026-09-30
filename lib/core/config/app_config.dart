import 'package:flutter/foundation.dart';

/// Cấu hình kết nối BE.
///
/// Mặc định trỏ tới BE chạy local (web/desktop: `localhost`, Android emulator:
/// `10.0.2.2`). Chạy trên điện thoại thật thì truyền IP máy chạy BE:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080/booking-app/api/v1`
abstract final class AppConfig {
  static const String _baseUrlFromEnv = String.fromEnvironment('API_BASE_URL');
  tháng sau
  static String get baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) return _baseUrlFromEnv;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/booking-app/api/v1';
    }
    return 'http://localhost:8080/booking-app/api/v1';
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 40);

  /// Link thanh toán VNPay sống 15 phút phía BE.
  static const Duration vnPayWindow = Duration(minutes: 15);

  /// BE trả ảnh dạng `/uploads/hotels/...`; ảnh được phục vụ ngay dưới base URL.
  static String? resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final value = path.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return value.startsWith('/') ? '$baseUrl$value' : '$baseUrl/$value';
  }
}
