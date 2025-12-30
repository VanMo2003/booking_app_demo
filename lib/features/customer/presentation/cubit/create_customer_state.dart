part of 'create_customer_cubit.dart';

@freezed
class CreateCustomerState with _$CreateCustomerState {
  const factory CreateCustomerState({
    @Default(CreateCustomerStatus.initial) CreateCustomerStatus status,
    String? errorMessage,
  }) = _CreateCustomerState;
}

enum CreateCustomerStatus { initial, loading, success, failure }
