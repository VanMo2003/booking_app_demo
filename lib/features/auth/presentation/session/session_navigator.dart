import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/text/auth_strings.dart';
import '../../../notification/services/push_service.dart';
import '../../../partner/domain/usecases/partner_usecases.dart';
import '../../domain/entities/session.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'session_cubit.dart';

/// Chọn "trang nhà" theo vai trò sau khi mở app hoặc đăng nhập.
abstract final class SessionNavigator {
  /// Trả về thông báo lỗi nếu không vào được (nhân viên chưa xác định cơ sở).
  static Future<String?> goHome(BuildContext context, Session? session) =>
      goHomeWith(context.rootRouter, context.read<SessionCubit>(), session);

  /// Như [goHome] nhưng không cần `BuildContext` — dùng khi mở app từ deep link
  /// hoặc thông báo đẩy.
  static Future<String?> goHomeWith(
    StackRouter router,
    SessionCubit sessionCubit,
    Session? session,
  ) async {
    if (session == null) {
      await router.replaceAll([const CustomerShellRoute()]);
      return null;
    }
    switch (session.role) {
      case Role.customer:
        await router.replaceAll([
          const CustomerShellRoute(),
          if (session.needsCustomerProfile) ProfileSetupRoute(),
        ]);
      case Role.staff:
        final hotelId = await getIt<ResolveStaffBranch>()(session);
        if (hotelId == null) return AuthStrings.branchNotResolved;
        if (session.staffHotelId != hotelId) {
          await sessionCubit.update(session.copyWith(staffHotelId: hotelId));
        }
        await router.replaceAll([WorkspaceShellRoute(hotelId: hotelId)]);
      case Role.hotelManager:
        await router.replaceAll([
          session.hotels.length == 1
              ? WorkspaceShellRoute(hotelId: session.hotels.first.id)
              : const BranchPickerRoute(),
        ]);
      case Role.hotelOwner:
        final chain = (await _refreshOwner(sessionCubit, session)).hotelChain;
        await router.replaceAll([
          if (chain == null)
            const CreateChainRoute()
          else if (chain.isApproved)
            const OwnerShellRoute()
          else
            const OwnerStatusRoute(),
        ]);
      case Role.admin:
        await router.replaceAll([const AdminShellRoute()]);
    }
    return null;
  }

  /// Chủ khách sạn chưa được duyệt: hỏi lại máy chủ vì hồ sơ có thể đã được
  /// duyệt trong lúc app tắt (mở app từ email / thông báo).
  static Future<Session> _refreshOwner(SessionCubit sessionCubit, Session session) async {
    final chain = session.hotelChain;
    if (chain == null || chain.isApproved) return session;
    try {
      final refreshed = await getIt<RefreshOwnerStatus>()(session);
      if (refreshed != session) await sessionCubit.update(refreshed);
      return refreshed;
    } catch (_) {
      // Mất mạng hoặc máy chủ lỗi — dùng trạng thái đã lưu, màn chờ duyệt tự kiểm tra lại.
      return session;
    }
  }

  static Future<void> logout(BuildContext context) async {
    final router = context.rootRouter;
    final sessionCubit = context.read<SessionCubit>();
    await getIt<PushService>().detach();
    await sessionCubit.logout();
    await router.replaceAll([const CustomerShellRoute()]);
  }
}
