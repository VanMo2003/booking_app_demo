import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/errors/app_exception.dart';
import '../../data/models/request/create_customer_request.dart';
import '../../domain/usecases/create_customer_use_case.dart';

part 'create_customer_state.dart';
part 'create_customer_cubit.freezed.dart';

class CreateCustomerCubit extends Cubit<CreateCustomerState> {
  final CreateCustomerUseCase _create;

  CreateCustomerCubit(this._create) : super(CreateCustomerState());

  Future<void> create(CreateCustomerRequest request) async {
    emit(state.copyWith(status: CreateCustomerStatus.loading));
    try {
      await _create.call(request);
      emit(state.copyWith(status: CreateCustomerStatus.success));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: CreateCustomerStatus.failure,
        errorMessage: e.message,
      ));
    }
  }
}
