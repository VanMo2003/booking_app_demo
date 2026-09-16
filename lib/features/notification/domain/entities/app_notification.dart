import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_enums.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.body = '',
    this.link,
    this.referenceId,
    this.read = false,
    this.createdAt,
  });

  final int id;
  final NotificationType type;
  final String title;
  final String body;

  /// Deep link `bookingapp://…` mở khi chạm vào thông báo.
  final String? link;

  /// Bản ghi mà thông báo nói tới (id chuỗi khách sạn với hồ sơ đối tác).
  final int? referenceId;
  final bool read;
  final DateTime? createdAt;

  AppNotification asRead() => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        link: link,
        referenceId: referenceId,
        read: true,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, type, title, body, link, referenceId, read, createdAt];
}
