import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/app_exception.dart';
import '../../../customer/data/models/customer_models.dart';
import '../../../customer/domain/usecases/customer_usecases.dart';
import '../session/session_cubit.dart';

enum ProfileSetupStep { link, create }

class ProfileSetupState extends Equatable {
  const ProfileSetupState({
    this.step = ProfileSetupStep.link,
    this.busy = false,
    this.done = false,
    this.notFoundPhone,
    this.error,
  });

  final ProfileSetupStep step;
  final bool busy;
  final bool done;

  /// Số điện thoại vừa tra không thấy hồ sơ vãng lai — điền sẵn vào form tạo mới.
  final String? notFoundPhone;
  final String? error;

  ProfileSetupState copyWith({
    ProfileSetupStep? step,
    bool? busy,
    bool? done,
    String? notFoundPhone,
    String? error,
  }) =>
      ProfileSetupState(
        step: step ?? this.step,
        busy: busy ?? this.busy,
        done: done ?? this.done,
        notFoundPhone: notFoundPhone ?? this.notFoundPhone,
        error: error,
      );

  @override
  List<Object?> get props => [step, busy, done, notFoundPhone, error];
}

@injectable
class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  ProfileSetupCubit(this._link, this._create, this._session)
      : super(const ProfileSetupState());

  final LinkWalkInProfile _link;
  final CreateCustomerProfile _create;
  final SessionCubit _session;

  void showCreateForm() => emit(state.copyWith(step: ProfileSetupStep.create));

  Future<void> linkByPhone(String phone) async {
    emit(state.copyWith(busy: true));
    try {
      final customer = await _link(phone.trim());
      final session = _session.session;
      if (session != null) await _session.update(session.copyWith(customer: customer));
      emit(state.copyWith(busy: false, done: true));
    } catch (error) {
      final failure = AppException.from(error);
      if (failure.isNotFound) {
        emit(state.copyWith(
          busy: false,
          step: ProfileSetupStep.create,
          notFoundPhone: phone.trim(),
        ));
      } else {
        emit(state.copyWith(busy: false, error: failure.message));
      }
    }
  }

  Future<void> create({
    required String fullName,
    required String phone,
    required String gender,
    required String hometown,
  }) async {
    final session = _session.session;
    if (session == null) return;
    emit(state.copyWith(busy: true));
    try {
      final customer = await _create(
        CustomerRequest(
          accountId: session.resolvedAccountId,
          fullName: fullName.trim(),
          phoneNumber: phone.trim(),
          gender: gender,
          hometown: hometown,
        ),
      );
      await _session.update(session.copyWith(customer: customer));
      emit(state.copyWith(busy: false, done: true));
    } catch (error) {
      emit(state.copyWith(busy: false, error: AppException.from(error).message));
    }
  }
}
