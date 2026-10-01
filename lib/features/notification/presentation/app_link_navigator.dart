import 'package:auto_route/auto_route.dart';

import '../../../core/di/injector.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/navigation/app_router.dart';
import '../../auth/domain/entities/session.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../auth/presentation/session/session_navigator.dart';
import '../../chat/presentation/chat_hub.dart';
import '../../partner/domain/usecases/partner_usecases.dart';
import '../services/app_link.dart';

/// Mở màn tương ứng với deep link từ email hoặc thông báo đẩy.
class AppLinkNavigator {
  const AppLinkNavigator(this._router, this._session);

  final StackRouter _router;
  final SessionCubit _session;

  Future<void> open(AppLink? link) async {
    if (link == null) return;
    final session = await _sessionReady();
    switch (link) {
      case OwnerStatusLink():
        await _openOwnerStatus(session);
      case NotificationsLink():
        if (session == null) {
          await _router.push(LoginRoute());
        } else if (!_router.isRouteActive(NotificationsRoute.name)) {
          await _router.push(const NotificationsRoute());
        }
      case OwnerRegistrationLink(:final chainId):
        if (session?.role == Role.admin) {
          await _router.push(OwnerRegistrationDetailRoute(chainId: chainId));
        }
      case TourBookingLink(:final bookingId):
        if (session == null) {
          await _router.push(LoginRoute());
        } else {
          await _router.push(TourBookingDetailRoute(bookingId: bookingId));
        }
      case ChatLink(:final conversationId):
        if (session == null) {
          await _router.push(LoginRoute());
        } else if (session.role != Role.admin &&
            !getIt<ChatHub>().isViewing(conversationId)) {
          await _router.push(ChatRoute(conversationId: conversationId));
        }
    }
  }

  /// Link mở app lúc khởi động: đợi màn chào khôi phục phiên và điều hướng xong.
  Future<Session?> _sessionReady() async {
    if (_session.state.status == SessionStatus.unknown) {
      await _session.stream.firstWhere((state) => state.status != SessionStatus.unknown);
    }
    for (var i = 0; i < 30 && _router.isRouteActive(SplashRoute.name); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    return _session.state.session;
  }

  Future<void> _openOwnerStatus(Session? session) async {
    if (session == null) {
      await _router.push(LoginRoute());
      return;
    }
    if (session.role != Role.hotelOwner) return;
    var current = session;
    try {
      current = await getIt<RefreshOwnerStatus>()(session);
      await _session.update(current);
    } catch (_) {
      // Mất mạng — dùng trạng thái đã lưu.
    }
    // Màn chờ duyệt đang mở tự chuyển khi trạng thái đổi.
    if (_router.isRouteActive(OwnerStatusRoute.name)) return;
    if ((current.hotelChain?.isApproved ?? false) &&
        _router.isRouteActive(OwnerShellRoute.name)) {
      _router.popUntilRouteWithName(OwnerShellRoute.name);
      return;
    }
    await SessionNavigator.goHomeWith(_router, _session, current);
  }
}
