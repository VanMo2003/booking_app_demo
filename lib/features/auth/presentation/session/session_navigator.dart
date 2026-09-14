import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/text/auth_strings.dart';
import '../../domain/entities/session.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'session_cubit.dart';

/// Chọn "trang nhà" theo vai trò sau khi mở app hoặc đăng nhập.
abstract final class SessionNavigator {
  /// Trả về thông báo lỗi nếu không vào được (nhân viên chưa xác định cơ sở).
  static Future<String?> goHome(BuildContext context, Session? session) async {
    final router = context.rootRouter;
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
        if (!context.mounted) return null;
        if (session.staffHotelId != hotelId) {
          await context
              .read<SessionCubit>()
              .update(session.copyWith(staffHotelId: hotelId));
        }
        await router.replaceAll([WorkspaceShellRoute(hotelId: hotelId)]);
      case Role.hotelManager:
        await router.replaceAll([
          session.hotels.length == 1
              ? WorkspaceShellRoute(hotelId: session.hotels.first.id)
              : const BranchPickerRoute(),
        ]);
      case Role.hotelOwner:
        await router.replaceAll([
          session.hotelChain == null
              ? const CreateChainRoute()
              : const OwnerShellRoute(),
        ]);
      case Role.admin:
        await router.replaceAll([const AdminShellRoute()]);
    }
    return null;
  }

  static Future<void> logout(BuildContext context) async {
    final router = context.rootRouter;
    await context.read<SessionCubit>().logout();
    await router.replaceAll([const CustomerShellRoute()]);
  }
}
