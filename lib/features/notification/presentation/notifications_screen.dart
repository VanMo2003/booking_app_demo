import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/bloc/paged_cubit.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/network/paged.dart';
import '../../../core/style/style.dart';
import '../../../core/text/notification_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../domain/entities/app_notification.dart';
import '../domain/usecases/notification_usecases.dart';
import '../services/app_link.dart';
import '../services/notification_events.dart';
import 'app_link_navigator.dart';
import 'notification_badge_cubit.dart';

@injectable
class NotificationsCubit extends PagedCubit<AppNotification> {
  NotificationsCubit(this._page, this._markRead, this._markAllRead);

  final GetNotificationsPage _page;
  final MarkNotificationRead _markRead;
  final MarkAllNotificationsRead _markAllRead;

  @override
  Future<Paged<AppNotification>> fetch({required int page, required int size}) =>
      _page(page: page, size: size);

  Future<void> markRead(AppNotification notification) async {
    if (notification.read) return;
    emit(state.copyWith(items: [
      for (final item in state.items) item.id == notification.id ? item.asRead() : item,
    ]));
    try {
      await _markRead(notification.id);
    } catch (_) {
      // Không quan trọng — lần tải sau sẽ đồng bộ lại.
    }
  }

  Future<ActionResult<void>> markAllRead() async {
    final result = await runAction(() => _markAllRead());
    if (result.isSuccess && !isClosed) {
      emit(state.copyWith(items: [for (final item in state.items) item.asRead()]));
    }
    return result;
  }
}

/// Hộp thông báo của tài khoản: kết quả xét duyệt, hồ sơ mới cần duyệt…
@RoutePage()
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationsCubit>()..load(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  StreamSubscription<void>? _events;

  @override
  void initState() {
    super.initState();
    _events = getIt<NotificationEvents>().onChanged.listen(
          (_) => context.read<NotificationsCubit>().load(),
        );
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  Future<void> _open(AppNotification notification) async {
    if (!notification.read) {
      context.read<NotificationBadgeCubit>().decrement();
      await context.read<NotificationsCubit>().markRead(notification);
    }
    if (!mounted) return;
    final link = AppLink.parse(notification.link);
    if (link == null) return;
    await AppLinkNavigator(context.rootRouter, context.read<SessionCubit>()).open(link);
  }

  Future<void> _markAllRead() async {
    final badge = context.read<NotificationBadgeCubit>();
    final result = await AppAction.run(
      context,
      context.read<NotificationsCubit>().markAllRead,
      successMessage: NotificationStrings.allRead,
      blocking: false,
    );
    if (result.isSuccess) badge.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, PagedState<AppNotification>>(
      builder: (context, state) {
        final cubit = context.read<NotificationsCubit>();
        final unread = state.items.where((item) => !item.read).length;
        return AppPage(
          title: NotificationStrings.title,
          subtitle: unread > 0 ? NotificationStrings.unreadCount(unread) : null,
          actions: [
            if (unread > 0)
              IconButton(
                tooltip: NotificationStrings.markAllRead,
                onPressed: _markAllRead,
                icon: const Icon(Icons.done_all_rounded),
              ),
          ],
          body: PagedListView<AppNotification>(
            state: state,
            onRefresh: cubit.load,
            onLoadMore: cubit.loadMore,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, AppSpacing.xl),
            empty: const AppStateView(
              illustration: AppIllustrationType.notifications,
              title: NotificationStrings.empty,
              description: NotificationStrings.emptyHint,
            ),
            itemBuilder: (context, notification) => _NotificationTile(
              notification: notification,
              onTap: () => _open(notification),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  static String _timeAgo(DateTime? time) {
    if (time == null) return '';
    final elapsed = DateTime.now().difference(time);
    if (elapsed.inMinutes < 1) return NotificationStrings.justNow;
    if (elapsed.inHours < 1) return NotificationStrings.minutesAgo(elapsed.inMinutes);
    if (elapsed.inDays < 1) return NotificationStrings.hoursAgo(elapsed.inHours);
    if (elapsed.inDays < 7) return NotificationStrings.daysAgo(elapsed.inDays);
    return Fmt.dateTime(time);
  }

  @override
  Widget build(BuildContext context) {
    final (icon, tone) = switch (notification.type) {
      NotificationType.ownerApproved => (Icons.verified_rounded, StatusTone.success),
      NotificationType.ownerRejected => (Icons.assignment_late_outlined, StatusTone.danger),
      NotificationType.ownerRegistered => (Icons.storefront_outlined, StatusTone.warning),
      NotificationType.tourBookingCreated => (Icons.tour_outlined, StatusTone.warning),
      NotificationType.tourBookingConfirmed => (Icons.event_available_rounded, StatusTone.success),
      NotificationType.tourBookingCanceled => (Icons.event_busy_rounded, StatusTone.danger),
      NotificationType.other => (Icons.notifications_none_rounded, StatusTone.brand),
    };
    final colors = tone.colors;
    final unread = !notification.read;
    return AppCard(
      onTap: onTap,
      color: unread ? AppColors.primarySoft.withValues(alpha: 0.4) : null,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: colors.foreground),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: unread ? AppTextStyles.bodyStrong : AppTextStyles.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8, top: 7),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (notification.body.isNotEmpty) ...[
                  const Gap(2),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Gap(4),
                Text(_timeAgo(notification.createdAt), style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
