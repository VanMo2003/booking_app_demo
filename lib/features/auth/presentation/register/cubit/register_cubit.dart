import 'package:bloc/bloc.dart';
import 'package:booking_app_mobile/features/auth/data/models/request/register_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/errors/app_exception.dart';
import '../../../domain/usecases/register_use_case.dart';

part 'register_state.dart';
part 'register_cubit.freezed.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase _register;

  RegisterCubit(this._register) : super(RegisterState());

  Future<void> register(RegisterRequest request) async {
    emit(state.copyWith(status: RegisterStatus.loading));
    try {
      await _register.call(request);
      emit(state.copyWith(status: RegisterStatus.success));
    } on AppException catch (e) {
      emit(state.copyWith(
          status: RegisterStatus.failure, errorMessage: e.message));
    }
  }
}
