import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color/app_colors.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/text/notification_strings.dart';
import 'notification_badge_cubit.dart';

/// Chuông thông báo kèm số chưa đọc; chạm để mở hộp thông báo.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key, this.onDark = false});

  /// Đặt trên đầu trang nền xanh.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationBadgeCubit>().state;
    return IconButton(
      tooltip: NotificationStrings.title,
      onPressed: () => context.rootRouter.push(const NotificationsRoute()),
      icon: Badge(
        isLabelVisible: unread > 0,
        backgroundColor: AppColors.danger,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: Icon(
          unread > 0 ? Icons.notifications_rounded : Icons.notifications_none_rounded,
          color: onDark ? AppColors.onPrimary : null,
        ),
      ),
    );
  }
}
