part of 'service_cubit.dart';

enum ServiceStatus { initial, loading, success, failure }

extension ServiceStatusX on ServiceStatus {
  bool get isLoading => this == ServiceStatus.loading;
  bool get isSuccess => this == ServiceStatus.success;
  bool get isFailure => this == ServiceStatus.failure;
  bool get isInitial => this == ServiceStatus.initial;
}

@freezed
class ServiceState with _$ServiceState {
  const factory ServiceState({
    @Default(ServiceStatus.initial) ServiceStatus status,
    List<ServiceEntity>? items,
    String? errorMessage,
  }) = _ServiceState;
}
