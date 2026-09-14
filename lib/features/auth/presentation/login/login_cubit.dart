import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/network/app_exception.dart';
import '../../domain/entities/session.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../session/session_cubit.dart';

class AuthFormState extends Equatable {
  const AuthFormState({this.status = ViewStatus.initial, this.session, this.error});

  final ViewStatus status;
  final Session? session;
  final String? error;

  bool get isLoading => status == ViewStatus.loading;

  @override
  List<Object?> get props => [status, session, error];
}

@injectable
class LoginCubit extends Cubit<AuthFormState> {
  LoginCubit(this._login, this._session) : super(const AuthFormState());

  final Login _login;
  final SessionCubit _session;

  Future<void> submit({required String username, required String password}) async {
    emit(const AuthFormState(status: ViewStatus.loading));
    try {
      final session = await _login(username: username, password: password);
      _session.signedIn(session);
      emit(AuthFormState(status: ViewStatus.success, session: session));
    } catch (error) {
      emit(AuthFormState(
        status: ViewStatus.failure,
        error: AppException.from(error).message,
      ));
    }
  }
}

@injectable
class RegisterCubit extends Cubit<AuthFormState> {
  RegisterCubit(this._register, this._session) : super(const AuthFormState());

  final RegisterCustomer _register;
  final SessionCubit _session;

  Future<void> submit({required String username, required String password}) async {
    emit(const AuthFormState(status: ViewStatus.loading));
    try {
      final session = await _register(username: username, password: password);
      _session.signedIn(session);
      emit(AuthFormState(status: ViewStatus.success, session: session));
    } catch (error) {
      emit(AuthFormState(
        status: ViewStatus.failure,
        error: AppException.from(error).message,
      ));
    }
  }
}
