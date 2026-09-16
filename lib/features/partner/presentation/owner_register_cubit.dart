import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/load_state.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/text/partner_strings.dart';
import '../../auth/domain/usecases/auth_usecases.dart';
import '../../auth/presentation/login/login_cubit.dart';
import '../../auth/presentation/session/session_cubit.dart';
import '../../hotel_chain/data/models/hotel_chain_models.dart';
import '../domain/usecases/partner_usecases.dart';

/// Gửi hồ sơ chủ khách sạn rồi đăng nhập luôn — tài khoản vào app ở màn chờ duyệt.
@injectable
class OwnerRegisterCubit extends Cubit<AuthFormState> {
  OwnerRegisterCubit(this._register, this._login, this._session)
      : super(const AuthFormState());

  final RegisterOwner _register;
  final Login _login;
  final SessionCubit _session;

  Future<void> submit({
    required String username,
    required String password,
    required HotelChainProfile profile,
  }) async {
    emit(const AuthFormState(status: ViewStatus.loading));
    try {
      await _register(username: username, password: password, profile: profile);
    } catch (error) {
      emit(AuthFormState(
        status: ViewStatus.failure,
        error: AppException.from(error).message,
      ));
      return;
    }
    try {
      final session = await _login(username: username, password: password);
      _session.signedIn(session);
      emit(AuthFormState(status: ViewStatus.success, session: session));
    } catch (_) {
      emit(const AuthFormState(
        status: ViewStatus.failure,
        error: PartnerStrings.registeredLoginFailed,
      ));
    }
  }
}
