part of "employee_cubit.dart";

enum EmployeeStatus { initial, loading, success, failure }

extension EmployeeStatusX on EmployeeStatus {
  bool get isLoading => this == EmployeeStatus.loading;

  bool get isSuccess => this == EmployeeStatus.success;

  bool get isFailure => this == EmployeeStatus.failure;

  bool get isInitial => this == EmployeeStatus.initial;
}

@freezed
class EmployeeState with _$EmployeeState {
  const factory EmployeeState({
    @Default(EmployeeStatus.initial) EmployeeStatus status,
    List<Employee>? employees,
    String? errorMessage,
  }) = _Initial;
}
