import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/color/app_colors.dart';
import '../../../core/color/status_colors.dart';
import '../../../core/component/component.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/router_extensions.dart';
import '../../../core/style/style.dart';
import '../../../core/text/notification_strings.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../domain/usecases/notification_usecases.dart';
import '../services/background_delivery.dart';

/// Thiết lập để vẫn nhận thông báo đẩy sau khi vuốt tắt app (Android): quyền thông báo, "Tự khởi chạy"
/// của Xiaomi/Oppo/Vivo…, bỏ giới hạn pin; kèm nút gửi thông báo thử. Trạng thái đọc lại mỗi khi quay
/// về từ trang cài đặt.
@RoutePage()
class NotificationSetupScreen extends StatefulWidget {
  const NotificationSetupScreen({super.key});

  @override
  State<NotificationSetupScreen> createState() => _NotificationSetupScreenState();
}

class _NotificationSetupScreenState extends State<NotificationSetupScreen> with WidgetsBindingObserver {
  final _delivery = getIt<BackgroundDelivery>();
  BackgroundDeliveryStatus? _status;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Vừa bật quyền trong trang cài đặt và quay lại.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final status = await _delivery.status();
    if (!mounted) return;
    setState(() {
      _status = status;
      _loading = false;
    });
  }

  Future<void> _sendTest() async {
    final result = await AppAction.run(context, () => runAction(() => getIt<SendTestPush>()()));
    final sent = result.value;
    if (sent == null || !mounted) return;
    if (!sent.pushEnabled) {
      AppToast.error(context, NotificationStrings.testServerOff);
    } else if (sent.devices == 0) {
      AppToast.error(context, NotificationStrings.testNoDevice);
    } else {
      AppToast.success(context, NotificationStrings.testSent(sent.delaySeconds));
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final signedIn = context.watch<SessionCubit>().state.session != null;
    return AppPage(
      title: NotificationStrings.setupTitle,
      body: _loading
          ? const AppLoadingView()
          : status == null
              ? const AppEmptyView(icon: Icons.notifications_off_outlined, title: NotificationStrings.notAndroid)
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: AppSpacing.page,
                    children: [
                      NoticeBanner(
                        tone: status.ready ? StatusTone.success : StatusTone.warning,
                        icon: status.ready ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                        text: status.ready ? NotificationStrings.setupReady : NotificationStrings.setupNeeded,
                      ),
                      const Gap(AppSpacing.md),
                      Text(NotificationStrings.setupIntro, style: AppTextStyles.bodySmall),
                      if (status.hasAutoStart) ...[
                        const Gap(AppSpacing.sm),
                        NoticeBanner(
                          icon: Icons.phone_android_rounded,
                          text: NotificationStrings.setupBrandHint(status.manufacturer),
                        ),
                      ],
                      const Gap(AppSpacing.md),
                      _SetupItem(
                        icon: Icons.notifications_active_outlined,
                        title: NotificationStrings.itemNotifications,
                        hint: NotificationStrings.itemNotificationsHint,
                        state: status.notificationsEnabled ? _ItemState.on : _ItemState.off,
                        actionLabel: NotificationStrings.openSettings,
                        onAction: _delivery.openNotificationSettings,
                      ),
                      if (status.hasAutoStart) ...[
                        const Gap(AppSpacing.sm),
                        _SetupItem(
                          icon: Icons.rocket_launch_outlined,
                          title: NotificationStrings.itemAutoStart,
                          hint: status.autoStart == AutoStartState.unknown
                              ? NotificationStrings.itemAutoStartUnknown
                              : NotificationStrings.itemAutoStartHint,
                          state: switch (status.autoStart) {
                            AutoStartState.allowed || AutoStartState.notNeeded => _ItemState.on,
                            AutoStartState.denied => _ItemState.off,
                            AutoStartState.unknown => _ItemState.check,
                          },
                          actionLabel: NotificationStrings.enable,
                          onAction: _delivery.openAutoStart,
                        ),
                      ],
                      const Gap(AppSpacing.sm),
                      _SetupItem(
                        icon: Icons.battery_charging_full_rounded,
                        title: NotificationStrings.itemBattery,
                        hint: NotificationStrings.itemBatteryHint,
                        state: status.batteryUnrestricted ? _ItemState.on : _ItemState.off,
                        actionLabel: NotificationStrings.allow,
                        onAction: _delivery.requestUnrestrictedBattery,
                      ),
                      if (signedIn) ...[
                        const Gap(AppSpacing.xl),
                        const SectionHeader(title: NotificationStrings.testTitle),
                        const Gap(AppSpacing.xs),
                        Text(NotificationStrings.testHint, style: AppTextStyles.bodySmall),
                        const Gap(AppSpacing.sm),
                        AppButton.tonal(
                          label: NotificationStrings.testSend,
                          icon: Icons.send_rounded,
                          expand: true,
                          onPressed: _sendTest,
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

enum _ItemState { on, off, check }

class _SetupItem extends StatelessWidget {
  const _SetupItem({
    required this.icon,
    required this.title,
    required this.hint,
    required this.state,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String hint;
  final _ItemState state;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (state) {
      _ItemState.on => (NotificationStrings.statusOn, StatusTone.success),
      _ItemState.off => (NotificationStrings.statusOff, StatusTone.danger),
      _ItemState.check => (NotificationStrings.statusCheck, StatusTone.warning),
    };
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyStrong),
                const Gap(2),
                Text(hint, style: AppTextStyles.caption),
                const Gap(6),
                StatusBadge(label: label, tone: tone, dense: true),
              ],
            ),
          ),
          if (state != _ItemState.on) ...[
            const Gap(AppSpacing.xs),
            AppButton(label: actionLabel, size: AppButtonSize.small, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

/// Dòng "Nhận thông báo khi tắt app" trong các menu, kèm trạng thái; chỉ hiện trên Android.
class NotificationSetupTile extends StatefulWidget {
  const NotificationSetupTile({super.key});

  @override
  State<NotificationSetupTile> createState() => _NotificationSetupTileState();
}

class _NotificationSetupTileState extends State<NotificationSetupTile> {
  final _delivery = getIt<BackgroundDelivery>();
  late Future<BackgroundDeliveryStatus?> _status = _delivery.status();

  @override
  Widget build(BuildContext context) {
    if (!_delivery.supported) return const SizedBox.shrink();
    return FutureBuilder<BackgroundDeliveryStatus?>(
      future: _status,
      builder: (context, snapshot) {
        final status = snapshot.data;
        return MenuTile(
          icon: Icons.notifications_paused_outlined,
          title: NotificationStrings.setupTitle,
          subtitle: status == null
              ? null
              : status.ready
                  ? NotificationStrings.statusOn
                  : NotificationStrings.setupNeeded,
          onTap: () async {
            await context.rootRouter.push(const NotificationSetupRoute());
            if (mounted) setState(() => _status = _delivery.status());
          },
        );
      },
    );
  }
}
