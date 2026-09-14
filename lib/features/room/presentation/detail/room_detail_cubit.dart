import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/app_exception.dart';
import '../../domain/entities/room.dart';
import '../../domain/usecases/room_usecases.dart';

class RoomDetailState extends Equatable {
  const RoomDetailState({
    this.detail = const LoadState(),
    this.checkin,
    this.checkout,
    this.statusForDates,
    this.checkingDates = false,
  });

  final LoadState<RoomDetail> detail;
  final DateTime? checkin;
  final DateTime? checkout;

  /// Trạng thái phòng trong khoảng ngày đã chọn (`/rooms/available`).
  final RoomStatus? statusForDates;
  final bool checkingDates;

  bool get hasDates => checkin != null && checkout != null;

  RoomDetailState copyWith({
    LoadState<RoomDetail>? detail,
    DateTime? checkin,
    DateTime? checkout,
    RoomStatus? statusForDates,
    bool? checkingDates,
  }) =>
      RoomDetailState(
        detail: detail ?? this.detail,
        checkin: checkin ?? this.checkin,
        checkout: checkout ?? this.checkout,
        statusForDates: statusForDates ?? this.statusForDates,
        checkingDates: checkingDates ?? this.checkingDates,
      );

  @override
  List<Object?> get props => [detail, checkin, checkout, statusForDates, checkingDates];
}

@injectable
class RoomDetailCubit extends Cubit<RoomDetailState> {
  RoomDetailCubit(this._getRoom, this._roomsForDates) : super(const RoomDetailState());

  final GetRoomDetail _getRoom;
  final GetRoomsForDates _roomsForDates;
  late int _roomId;
  late int _hotelId;

  Future<void> load({
    required int roomId,
    required int hotelId,
    DateTime? checkin,
    DateTime? checkout,
  }) async {
    _roomId = roomId;
    _hotelId = hotelId;
    emit(RoomDetailState(detail: state.detail.toLoading(), checkin: checkin, checkout: checkout));
    try {
      final room = await _getRoom(roomId);
      if (isClosed) return;
      emit(state.copyWith(detail: state.detail.toSuccess(room)));
      if (state.hasDates) await _checkDates();
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(detail: state.detail.toFailure(AppException.from(error).message)));
      }
    }
  }

  Future<void> changeDates(DateTimeRange range) async {
    emit(state.copyWith(checkin: range.start, checkout: range.end));
    await _checkDates();
  }

  Future<void> _checkDates() async {
    emit(state.copyWith(checkingDates: true));
    try {
      final rooms = await _roomsForDates(
        hotelId: _hotelId,
        checkin: state.checkin!,
        checkout: state.checkout!,
      );
      final match = rooms.firstWhereOrNull((room) => room.id == _roomId);
      if (!isClosed) {
        emit(state.copyWith(
          checkingDates: false,
          statusForDates: match?.status ?? RoomStatus.booked,
        ));
      }
    } catch (_) {
      if (!isClosed) emit(state.copyWith(checkingDates: false));
    }
  }
}
