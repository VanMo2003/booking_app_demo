import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'dev_host.dart';

/// Cấu hình kết nối BE.
///
/// - `API_BASE_URL` (dart-define): URL đầy đủ, dùng khi trỏ tới máy chủ khác:
///   `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080/booking-app/api/v1`
/// - Điện thoại thật: [devHost] — dòng `IPv4 Address` của card Wi-Fi trong `ipconfig` trên laptop
///   build app (Gradle tự ghi lúc build) — ghép thành `http://<ipv4>:8080/booking-app/api/v1`.
/// - Emulator, web, desktop: Android `10.0.2.2`, còn lại `localhost`.
abstract final class AppConfig {
  static const String _baseUrlFromEnv = String.fromEnvironment('API_BASE_URL');
  static const int _port = 8080;
  static const String _apiPath = '/booking-app/api/v1';

  /// Chạy trên điện thoại thật (không phải emulator), xác định lúc mở app.
  static bool _physicalPhone = false;

  static String get baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) return _baseUrlFromEnv;
    if (_physicalPhone && devHost != null) return 'http://$devHost:$_port$_apiPath';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$_port$_apiPath';
    }
    return 'http://localhost:$_port$_apiPath';
  }

  /// Gọi một lần ở `main`, trước khi dựng DI (Dio lấy [baseUrl] lúc tạo).
  static Future<void> init() async {
    _physicalPhone = await _isPhysicalPhone();
    debugPrint('BE: $baseUrl');
  }

  /// Emulator gọi máy tính qua `10.0.2.2`; chỉ máy thật mới dùng IPv4 của laptop.
  static Future<bool> _isPhysicalPhone() async {
    if (kIsWeb) return false;
    try {
      final info = DeviceInfoPlugin();
      return switch (defaultTargetPlatform) {
        TargetPlatform.android => (await info.androidInfo).isPhysicalDevice,
        TargetPlatform.iOS => (await info.iosInfo).isPhysicalDevice,
        _ => false,
      };
    } catch (_) {
      return false;
    }
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
