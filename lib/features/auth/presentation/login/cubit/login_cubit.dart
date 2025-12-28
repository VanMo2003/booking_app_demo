import 'package:bloc/bloc.dart';
import 'package:booking_app_mobile/features/auth/data/models/request/login_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/errors/app_exception.dart';
import '../../../domain/entity/auth.dart';
import '../../../domain/usecases/login_use_case.dart';

part 'login_state.dart';
part 'login_cubit.freezed.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _login;

  LoginCubit(this._login) : super(LoginState());

  Future<void> login(LoginRequest request) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final res = await _login.call(request);
      if (res.authenticated) {
        emit(state.copyWith(status: LoginStatus.success, login: res));
      }
    } on AppException catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    }
  }
}
