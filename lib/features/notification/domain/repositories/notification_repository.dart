import '../../../../core/network/paged.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<Paged<AppNotification>> page({required int page, required int size});

  Future<int> unreadCount();

  Future<AppNotification> markRead(int id);

  Future<void> markAllRead();

  Future<void> registerDevice({required String token, required String platform});

  Future<void> unregisterDevice(String token);
}
