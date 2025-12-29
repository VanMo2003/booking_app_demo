part of 'register_cubit.dart';

enum RegisterStatus { initial, loading, success, failure }

extension RegisterStatusX on RegisterStatus {
  bool get isLoading => this == RegisterStatus.loading;
  bool get isSuccess => this == RegisterStatus.success;
  bool get isFailure => this == RegisterStatus.failure;
  bool get isInitial => this == RegisterStatus.initial;
}

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default(RegisterStatus.initial) RegisterStatus status,
    String? errorMessage,
  }) = _Initial;
}
