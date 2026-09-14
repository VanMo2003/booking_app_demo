import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/network/app_exception.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/usecases/hotel_usecases.dart';

class HotelDetailState extends Equatable {
  const HotelDetailState({
    this.detail = const LoadState(),
    this.checkin,
    this.checkout,
  });

  final LoadState<HotelDetail> detail;
  final DateTime? checkin;
  final DateTime? checkout;

  bool get hasDates => checkin != null && checkout != null;

  HotelDetailState copyWith({
    LoadState<HotelDetail>? detail,
    DateTime? checkin,
    DateTime? checkout,
  }) =>
      HotelDetailState(
        detail: detail ?? this.detail,
        checkin: checkin ?? this.checkin,
        checkout: checkout ?? this.checkout,
      );

  @override
  List<Object?> get props => [detail, checkin, checkout];
}

@injectable
class HotelDetailCubit extends Cubit<HotelDetailState> {
  HotelDetailCubit(this._getDetail) : super(const HotelDetailState());

  final GetHotelDetail _getDetail;
  late int _hotelId;

  Future<void> load(int hotelId, {DateTime? checkin, DateTime? checkout}) {
    _hotelId = hotelId;
    emit(HotelDetailState(
      detail: state.detail.toLoading(),
      checkin: checkin,
      checkout: checkout,
    ));
    return _fetch();
  }

  Future<void> refresh() => _fetch();

  /// Đổi ngày → BE tính lại trạng thái từng phòng cho khoảng mới.
  Future<void> changeDates(DateTimeRange range) {
    emit(state.copyWith(
      checkin: range.start,
      checkout: range.end,
      detail: state.detail.toLoading(),
    ));
    return _fetch();
  }

  Future<void> _fetch() async {
    try {
      final detail = await _getDetail(
        _hotelId,
        checkin: state.checkin,
        checkout: state.checkout,
      );
      if (!isClosed) emit(state.copyWith(detail: state.detail.toSuccess(detail)));
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(
          detail: state.detail.toFailure(AppException.from(error).message),
        ));
      }
    }
  }
}
