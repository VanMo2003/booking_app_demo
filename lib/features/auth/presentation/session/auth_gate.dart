import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/component/feedback.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/router_extensions.dart';
import '../../../../core/text/auth_strings.dart';
import '../../../customer/domain/entities/customer.dart';
import 'session_cubit.dart';

/// Cổng đăng nhập: khách vãng lai duyệt tự do, chỉ bị hỏi đăng nhập khi dùng
/// tính năng gắn với tài khoản (đặt phòng, yêu thích, đơn của tôi).
extension AuthGate on BuildContext {
  Future<bool> ensureSignedIn() async {
    final cubit = read<SessionCubit>();
    if (!cubit.state.isGuest) return true;
    final result = await rootRouter.push<bool>(LoginRoute(returnResult: true));
    return result == true && !cubit.state.isGuest;
  }

  /// Bảo đảm người dùng là khách hàng đã có hồ sơ; trả hồ sơ hoặc `null` nếu huỷ.
  Future<Customer?> ensureCustomer() async {
    if (!await ensureSignedIn()) return null;
    if (!mounted) return null;
    final cubit = read<SessionCubit>();
    final session = cubit.state.session;
    if (session == null) return null;
    if (session.role != Role.customer) {
      AppToast.info(this, AuthStrings.customerOnly);
      return null;
    }
    if (session.customer == null) {
      final done = await rootRouter.push<bool>(ProfileSetupRoute(returnResult: true));
      if (done != true) return null;
    }
    return cubit.state.session?.customer;
  }
}
