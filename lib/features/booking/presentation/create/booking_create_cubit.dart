import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../hotel/domain/entities/hotel.dart';
import '../../../hotel/domain/usecases/hotel_usecases.dart';
import '../../../room/domain/entities/room.dart';
import '../../../service/domain/entities/hotel_service.dart';
import '../../data/models/booking_models.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_pricing.dart';
import '../../domain/usecases/booking_usecases.dart';

class BookingCreateState extends Equatable {
  const BookingCreateState({
    required this.checkin,
    required this.checkout,
    this.detail = const LoadState(),
    this.selectedRoomIds = const {},
    this.selectedServiceIds = const {},
    this.paymentMethod = PaymentMethod.vnPay,
    this.submitting = false,
    this.created,
    this.error,
  });

  final DateTime checkin;
  final DateTime checkout;

  /// Chi tiết cơ sở kèm trạng thái phòng theo ngày đã chọn.
  final LoadState<HotelDetail> detail;
  final Set<int> selectedRoomIds;
  final Set<int> selectedServiceIds;
  final PaymentMethod paymentMethod;
  final bool submitting;
  final Booking? created;
  final String? error;

  int get nights => DateOnly.nights(checkin, checkout);

  List<Room> get selectedRooms => (detail.data?.rooms ?? const <Room>[])
      .where((room) => selectedRoomIds.contains(room.id))
      .toList();

  List<HotelService> get selectedServices =>
      (detail.data?.hotel.services ?? const <HotelService>[])
          .where((service) => selectedServiceIds.contains(service.id))
          .toList();

  BookingPricing get pricing => BookingPricing(
        rooms: selectedRooms,
        services: selectedServices,
        nights: nights,
      );

  bool get canSubmit =>
      detail.hasData && !detail.isLoading && selectedRoomIds.isNotEmpty && !submitting;

  BookingCreateState copyWith({
    DateTime? checkin,
    DateTime? checkout,
    LoadState<HotelDetail>? detail,
    Set<int>? selectedRoomIds,
    Set<int>? selectedServiceIds,
    PaymentMethod? paymentMethod,
    bool? submitting,
    Booking? created,
    String? error,
  }) =>
      BookingCreateState(
        checkin: checkin ?? this.checkin,
        checkout: checkout ?? this.checkout,
        detail: detail ?? this.detail,
        selectedRoomIds: selectedRoomIds ?? this.selectedRoomIds,
        selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        submitting: submitting ?? this.submitting,
        created: created ?? this.created,
        error: error,
      );

  @override
  List<Object?> get props => [
        checkin,
        checkout,
        detail,
        selectedRoomIds,
        selectedServiceIds,
        paymentMethod,
        submitting,
        created,
        error,
      ];
}

/// Dùng chung cho khách tự đặt và lễ tân đặt tại quầy.
@injectable
class BookingCreateCubit extends Cubit<BookingCreateState> {
  BookingCreateCubit(this._getDetail, this._createBooking)
      : super(BookingCreateState(
          checkin: DateOnly.today(),
          checkout: DateOnly.addDays(DateOnly.today(), 1),
        ));

  final GetHotelDetail _getDetail;
  final CreateBooking _createBooking;
  late int _hotelId;

  Future<void> start({
    required int hotelId,
    required DateTime checkin,
    required DateTime checkout,
    List<int> preselectedRoomIds = const [],
    PaymentMethod paymentMethod = PaymentMethod.vnPay,
  }) {
    _hotelId = hotelId;
    emit(BookingCreateState(
      checkin: checkin,
      checkout: checkout,
      selectedRoomIds: preselectedRoomIds.toSet(),
      paymentMethod: paymentMethod,
      detail: const LoadState(status: ViewStatus.loading),
    ));
    return _fetch();
  }

  /// Tải lại chi tiết cơ sở sau lỗi.
  Future<void> reload() {
    emit(state.copyWith(detail: state.detail.toLoading()));
    return _fetch();
  }

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
      final bookable = detail.availableRooms.map((room) => room.id).toSet();
      if (!isClosed) {
        emit(state.copyWith(
          detail: state.detail.toSuccess(detail),
          selectedRoomIds: state.selectedRoomIds.intersection(bookable),
        ));
      }
    } catch (error) {
      if (!isClosed) emit(state.copyWith(detail: state.detail.toError(error)));
    }
  }

  void toggleRoom(int roomId) {
    final ids = {...state.selectedRoomIds};
    ids.contains(roomId) ? ids.remove(roomId) : ids.add(roomId);
    emit(state.copyWith(selectedRoomIds: ids));
  }

  void toggleService(int serviceId) {
    final ids = {...state.selectedServiceIds};
    ids.contains(serviceId) ? ids.remove(serviceId) : ids.add(serviceId);
    emit(state.copyWith(selectedServiceIds: ids));
  }

  void selectPayment(PaymentMethod method) =>
      emit(state.copyWith(paymentMethod: method));

  Future<void> submit({required int customerId, String? note}) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(submitting: true));
    try {
      final booking = await _createBooking(
        BookingCreateRequest(
          checkinDate: state.checkin,
          checkoutDate: state.checkout,
          paymentMethod: state.paymentMethod,
          hotelId: _hotelId,
          customerId: customerId,
          roomIds: state.selectedRoomIds.toList(),
          serviceIds: state.selectedServiceIds.toList(),
          totalAmount: state.pricing.total,
          note: note?.trim(),
        ),
      );
      if (!isClosed) emit(state.copyWith(submitting: false, created: booking));
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(submitting: false, error: AppException.from(error).message));
        // Phòng có thể vừa bị người khác đặt — tải lại trạng thái phòng.
        await _fetch();
      }
    }
  }
}
