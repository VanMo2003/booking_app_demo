import 'package:injectable/injectable.dart';

import '../../../../core/network/json_reader.dart';
import '../../../../core/network/paged.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_api.dart';
import '../models/notification_models.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._api);

  final NotificationApi _api;

  @override
  Future<Paged<AppNotification>> page({required int page, required int size}) async =>
      (await _api.getMine(page, size)).parsePage(AppNotificationModel.fromJson);

  @override
  Future<int> unreadCount() async => (await _api.unreadCount()).json.integer('unread');

  @override
  Future<AppNotification> markRead(int id) async =>
      (await _api.markRead(id)).parse(AppNotificationModel.fromJson);

  @override
  Future<void> markAllRead() async => (await _api.markAllRead()).ensureSuccess();

  @override
  Future<void> registerDevice({required String token, required String platform}) async =>
      (await _api.registerDevice({'token': token, 'platform': platform})).ensureSuccess();

  @override
  Future<void> unregisterDevice(String token) async =>
      (await _api.unregisterDevice(token)).ensureSuccess();
}
