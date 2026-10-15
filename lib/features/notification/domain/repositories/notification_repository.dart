import '../../../../core/network/paged.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<Paged<AppNotification>> page({required int page, required int size});

  Future<int> unreadCount();

  Future<AppNotification> markRead(int id);

  Future<void> markAllRead();

  Future<void> registerDevice({required String token, required String platform});

  Future<void> unregisterDevice(String token);

  Future<TestPushResult> sendTestPush({int delaySeconds = 10});
}

/// Kết quả yêu cầu gửi thông báo thử.
class TestPushResult {
  const TestPushResult({required this.pushEnabled, required this.devices, required this.delaySeconds});

  /// Máy chủ đã cấu hình Firebase (`FIREBASE_CREDENTIALS`).
  final bool pushEnabled;

  /// Số thiết bị của tài khoản đã đăng ký nhận thông báo.
  final int devices;
  final int delaySeconds;
}
