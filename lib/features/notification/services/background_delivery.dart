import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// "Tự khởi chạy" (Autostart) của Xiaomi/Oppo/Vivo/Huawei…: tắt thì máy chặn thông báo khi app đã tắt.
enum AutoStartState {
  allowed,
  denied,

  /// Hãng có mục này nhưng không đọc được trạng thái — người dùng tự kiểm tra.
  unknown,

  /// Máy không có mục này (Pixel, Samsung…).
  notNeeded;

  static AutoStartState parse(String? raw) =>
      AutoStartState.values.firstWhere((s) => s.name == raw, orElse: () => AutoStartState.unknown);
}

/// Những gì quyết định máy còn nhận thông báo đẩy sau khi app bị vuốt tắt.
class BackgroundDeliveryStatus {
  const BackgroundDeliveryStatus({
    required this.manufacturer,
    required this.notificationsEnabled,
    required this.batteryUnrestricted,
    required this.autoStart,
  });

  factory BackgroundDeliveryStatus.fromMap(Map<String, dynamic> map) => BackgroundDeliveryStatus(
        manufacturer: map['manufacturer'] as String? ?? '',
        notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
        batteryUnrestricted: map['batteryUnrestricted'] as bool? ?? false,
        autoStart: AutoStartState.parse(map['autoStart'] as String?),
      );

  final String manufacturer;
  final bool notificationsEnabled;
  final bool batteryUnrestricted;
  final AutoStartState autoStart;

  bool get hasAutoStart => autoStart != AutoStartState.notNeeded;

  bool get autoStartOk => autoStart == AutoStartState.allowed || autoStart == AutoStartState.notNeeded;

  /// Đủ cả ba: thông báo bật, không giới hạn pin, tự khởi chạy (nếu máy có mục này).
  bool get ready => notificationsEnabled && batteryUnrestricted && autoStartOk;
}

/// Đọc trạng thái và mở các trang cài đặt liên quan qua kênh native `booking_app/notification_setup`
/// (`NotificationSetup.kt`). Chỉ Android; nền tảng khác trả `null` / không làm gì.
@lazySingleton
class BackgroundDelivery {
  static const _channel = MethodChannel('booking_app/notification_setup');

  bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<BackgroundDeliveryStatus?> status() async {
    if (!supported) return null;
    try {
      final map = await _channel.invokeMapMethod<String, dynamic>('status');
      return map == null ? null : BackgroundDeliveryStatus.fromMap(map);
    } on Exception {
      return null;
    }
  }

  Future<void> openNotificationSettings() => _invoke('openNotificationSettings');

  /// Trang "Tự khởi chạy" của hãng (không có thì trang thông tin app).
  Future<void> openAutoStart() => _invoke('openAutoStart');

  /// Hộp thoại hệ thống "Cho phép app chạy nền / bỏ tối ưu pin".
  Future<void> requestUnrestrictedBattery() => _invoke('requestUnrestrictedBattery');

  Future<void> _invoke(String method) async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<bool>(method);
    } on Exception {
      // Máy không có trang này — không có gì để mở.
    }
  }
}
