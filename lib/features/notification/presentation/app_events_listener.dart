import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/component/feedback.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/storage/app_preferences.dart';
import '../../../core/text/notification_strings.dart';
import '../../ai/domain/usecases/ai_usecases.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../chat/presentation/chat_hub.dart';
import '../services/app_link.dart';
import '../services/background_delivery.dart';
import '../services/deep_link_service.dart';
import '../services/notification_events.dart';
import '../services/push_service.dart';
import 'app_link_navigator.dart';
import 'notification_badge_cubit.dart';

/// Nối thông báo đẩy, deep link và vòng đời app với phiên đăng nhập:
/// - vừa đăng nhập: đăng ký thiết bị nhận push, đếm thông báo chưa đọc;
/// - app đang mở: có thông báo mới (push, hoặc kiểm tra định kỳ khi không có
///   Firebase) thì hiện toast và báo các màn liên quan tải lại;
/// - chạm thông báo / mở link từ email: tới đúng màn;
/// - kênh chat realtime mở/đóng theo phiên và theo app đang mở hay chạy nền.
class AppEventsListener extends StatefulWidget {
  const AppEventsListener({super.key, required this.router, required this.child});

  final AppRouter router;
  final Widget child;

  @override
  State<AppEventsListener> createState() => _AppEventsListenerState();
}

class _AppEventsListenerState extends State<AppEventsListener> with WidgetsBindingObserver {
  static const _pollInterval = Duration(seconds: 45);
  static const _setupAskedKey = 'notification.background_setup_asked';

  final _session = getIt<SessionCubit>();
  final _badge = getIt<NotificationBadgeCubit>();
  final _push = getIt<PushService>();
  final _events = getIt<NotificationEvents>();
  final _chat = getIt<ChatHub>();
  final _subscriptions = <StreamSubscription<Object?>>[];
  late final _links = AppLinkNavigator(widget.router, _session);
  Timer? _poll;
  String? _signedInUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscriptions.addAll([
      _session.stream.listen(_onSession),
      _push.onForegroundMessage.listen(_onForegroundMessage),
      _push.onOpened.listen(_openLink),
      getIt<DeepLinkService>().links.listen(_openLink),
    ]);
    final initialLink = _push.takeInitialLink();
    if (initialLink != null) _openLink(initialLink);
    _onSession(_session.state);
    // Máy chủ có bật AI không — để hiện/ẩn các nút AI.
    getIt<AiAvailability>().refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _poll?.cancel();
    super.dispose();
  }

  void _onSession(SessionState state) {
    final username = state.session?.username;
    if (username == _signedInUser) return;
    _signedInUser = username;
    _chat.onSession(state.session);
    _poll?.cancel();
    _poll = null;
    _badge.reset();
    if (username == null) return;
    _push.attach();
    _askBackgroundSetupOnce();
    _badge.refresh();
    _poll = Timer.periodic(_pollInterval, (_) => _checkForNew());
  }

  /// Máy (thường Xiaomi/Oppo/Vivo) đang chặn thông báo khi app đã tắt: hỏi một lần, đồng ý thì mở
  /// màn thiết lập. Sau đó người dùng tự vào "Nhận thông báo khi tắt app" trong menu.
  Future<void> _askBackgroundSetupOnce() async {
    final delivery = getIt<BackgroundDelivery>();
    final prefs = getIt<AppPreferences>();
    if (!delivery.supported || prefs.getInt(_setupAskedKey) != null) return;
    // Để màn chính sau đăng nhập hiện xong trước.
    await Future<void>.delayed(const Duration(seconds: 3));
    final status = await delivery.status();
    if (status == null || status.ready || _signedInUser == null) return;
    await prefs.setInt(_setupAskedKey, 1);
    final context = widget.router.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    final setUp = await AppDialogs.confirm(
      context,
      title: NotificationStrings.promptTitle,
      message: NotificationStrings.promptMessage,
      confirmLabel: NotificationStrings.promptConfirm,
      cancelLabel: NotificationStrings.promptLater,
      icon: Icons.notifications_active_outlined,
    );
    if (setUp) await widget.router.push(const NotificationSetupRoute());
  }

  Future<void> _checkForNew() async {
    final newest = await _badge.refresh();
    if (newest == null) return;
    AppToast.infoGlobal(newest.title);
    _events.notifyChanged();
  }

  void _onForegroundMessage(PushMessage message) {
    if (AppLink.parse(message.link) case ChatLink(:final conversationId)) {
      // Tin nhắn chỉ được đẩy khi kênh chat đang ngắt; đang xem đúng cuộc đó thì bỏ qua toast.
      getIt<ChatUnreadCubit>().refresh();
      if (_chat.isViewing(conversationId)) return;
      AppToast.infoGlobal(message.body.isEmpty ? message.title : '${message.title}: ${message.body}');
      return;
    }
    _badge.refresh();
    if (message.title.isNotEmpty) AppToast.infoGlobal(message.title);
    _events.notifyChanged();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _chat.onLifecycle(state);
    if (state != AppLifecycleState.resumed || _signedInUser == null) return;
    _checkForNew();
    _events.notifyChanged();
  }

  void _openLink(String link) => _links.open(AppLink.parse(link));

  @override
  Widget build(BuildContext context) => widget.child;
}
