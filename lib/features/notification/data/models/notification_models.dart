import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/app_notification.dart';

/// JSON `NotificationResponse` → [AppNotification].
abstract final class AppNotificationModel {
  static AppNotification fromJson(Json json) => AppNotification(
        id: json.integer('id'),
        type: NotificationType.parse(json.strOrNull('type')),
        title: json.str('title'),
        body: json.str('body'),
        link: json.strOrNull('link'),
        referenceId: json.intOrNull('referenceId'),
        read: json.flag('read'),
        createdAt: json.dateTime('onCreate'),
      );
}
