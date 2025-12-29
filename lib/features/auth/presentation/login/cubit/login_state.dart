part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, failure }

extension LoginStatusX on LoginStatus {
  bool get isLoading => this == LoginStatus.loading;

  bool get isSuccess => this == LoginStatus.success;

  bool get isFailure => this == LoginStatus.failure;

  bool get isInitial => this == LoginStatus.initial;
}

@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    @Default(LoginStatus.initial) LoginStatus status,
    AuthResponse? authResponse,
    String? errorMessage,
  }) = _Initial;
}
