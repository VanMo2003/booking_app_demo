import 'package:injectable/injectable.dart';

import '../../../../core/network/paged.dart';
import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

@injectable
class GetNotificationsPage {
  const GetNotificationsPage(this._repository);

  final NotificationRepository _repository;

  Future<Paged<AppNotification>> call({required int page, required int size}) =>
      _repository.page(page: page, size: size);
}

@injectable
class GetUnreadNotificationCount {
  const GetUnreadNotificationCount(this._repository);

  final NotificationRepository _repository;

  Future<int> call() => _repository.unreadCount();
}

@injectable
class MarkNotificationRead {
  const MarkNotificationRead(this._repository);

  final NotificationRepository _repository;

  Future<AppNotification> call(int id) => _repository.markRead(id);
}

@injectable
class MarkAllNotificationsRead {
  const MarkAllNotificationsRead(this._repository);

  final NotificationRepository _repository;

  Future<void> call() => _repository.markAllRead();
}

/// Nút "Gửi thông báo thử": kiểm tra máy vẫn nhận thông báo khi app đã tắt.
@injectable
class SendTestPush {
  const SendTestPush(this._repository);

  final NotificationRepository _repository;

  Future<TestPushResult> call({int delaySeconds = 10}) => _repository.sendTestPush(delaySeconds: delaySeconds);
}

@injectable
class RegisterPushDevice {
  const RegisterPushDevice(this._repository);

  final NotificationRepository _repository;

  Future<void> call({required String token, required String platform}) =>
      _repository.registerDevice(token: token, platform: platform);
}

@injectable
class UnregisterPushDevice {
  const UnregisterPushDevice(this._repository);

  final NotificationRepository _repository;

  Future<void> call(String token) => _repository.unregisterDevice(token);
}
