import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../domain/entities/app_notification.dart';
import '../domain/usecases/notification_usecases.dart';

/// Số thông báo chưa đọc của tài khoản đang đăng nhập (số trên chuông).
@lazySingleton
class NotificationBadgeCubit extends Cubit<int> {
  NotificationBadgeCubit(this._count, this._page) : super(0);

  final GetUnreadNotificationCount _count;
  final GetNotificationsPage _page;
  bool _primed = false;

  /// Làm mới số chưa đọc. Trả thông báo mới nhất khi số chưa đọc vừa tăng; lần
  /// đầu sau khi đăng nhập chỉ đếm, không báo lại thông báo cũ.
  Future<AppNotification?> refresh() async {
    try {
      final previous = state;
      final unread = await _count();
      if (isClosed) return null;
      emit(unread);
      final announce = _primed && unread > previous;
      _primed = true;
      if (!announce) return null;
      final newest = (await _page(page: 0, size: 1)).items.firstOrNull;
      return newest == null || newest.read ? null : newest;
    } catch (_) {
      return null;
    }
  }

  void decrement() {
    if (state > 0) emit(state - 1);
  }

  void clear() => emit(0);

  /// Đăng xuất hoặc đổi tài khoản.
  void reset() {
    _primed = false;
    emit(0);
  }
}
