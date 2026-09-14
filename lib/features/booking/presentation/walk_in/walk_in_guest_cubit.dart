import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/app_exception.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/domain/usecases/customer_usecases.dart';

class WalkInGuestState extends Equatable {
  const WalkInGuestState({
    this.searching = false,
    this.searchedPhone,
    this.results = const [],
    this.selected,
    this.creating = false,
    this.error,
  });

  final bool searching;

  /// Số điện thoại đã tra — `null` khi chưa tra lần nào.
  final String? searchedPhone;
  final List<Customer> results;
  final Customer? selected;
  final bool creating;
  final String? error;

  bool get notFound => searchedPhone != null && !searching && results.isEmpty;

  WalkInGuestState copyWith({
    bool? searching,
    String? searchedPhone,
    List<Customer>? results,
    Customer? selected,
    bool clearSelected = false,
    bool? creating,
    String? error,
  }) =>
      WalkInGuestState(
        searching: searching ?? this.searching,
        searchedPhone: searchedPhone ?? this.searchedPhone,
        results: results ?? this.results,
        selected: clearSelected ? null : selected ?? this.selected,
        creating: creating ?? this.creating,
        error: error,
      );

  @override
  List<Object?> get props => [searching, searchedPhone, results, selected, creating, error];
}

/// Bước 1 đặt tại quầy: tra hồ sơ theo SĐT để tránh tạo trùng, không có thì tạo mới.
@injectable
class WalkInGuestCubit extends Cubit<WalkInGuestState> {
  WalkInGuestCubit(this._find, this._create) : super(const WalkInGuestState());

  final FindCustomersByPhone _find;
  final CreateWalkInCustomer _create;

  Future<void> search(String phone) async {
    emit(state.copyWith(searching: true, searchedPhone: phone.trim(), clearSelected: true));
    try {
      final results = await _find(phone);
      emit(state.copyWith(
        searching: false,
        results: results,
        selected: results.length == 1 ? results.first : null,
      ));
    } catch (error) {
      emit(state.copyWith(searching: false, results: const [], error: AppException.from(error).message));
    }
  }

  void select(Customer customer) => emit(state.copyWith(selected: customer));

  void reset() => emit(const WalkInGuestState());

  Future<void> createAndSelect({
    required String fullName,
    required String phone,
    required String gender,
    required String hometown,
  }) async {
    emit(state.copyWith(creating: true));
    try {
      final customer = await _create(
        fullName: fullName.trim(),
        phoneNumber: phone.trim(),
        gender: gender,
        hometown: hometown,
      );
      emit(state.copyWith(creating: false, results: [customer], selected: customer));
    } catch (error) {
      emit(state.copyWith(creating: false, error: AppException.from(error).message));
    }
  }
}
