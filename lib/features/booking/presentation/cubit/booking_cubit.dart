import 'package:bloc/bloc.dart';
import 'package:booking_app_mobile/features/booking/domain/usecases/get_booking_use_case.dart'
    show GetBookings;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/request/booking_create_request.dart';
import '../../domain/entity/booking_entity.dart';
import '../../domain/usecases/cancel_booking_use_case.dart';
import '../../domain/usecases/complete_booking_use_case.dart';
import '../../domain/usecases/confirm_booking_use_case.dart';
import '../../domain/usecases/create_booking_use_case.dart';

part 'booking_state.dart';
part 'booking_cubit.freezed.dart';

class BookingCubit extends Cubit<BookingState> {
  final GetBookings getBookings;
  final CreateBooking createBooking;
  final ConfirmBooking confirmBooking;
  final CancelBooking cancelBooking;
  final CompleteBooking completeBooking;

  BookingCubit({
    required this.getBookings,
    required this.createBooking,
    required this.confirmBooking,
    required this.cancelBooking,
    required this.completeBooking,
  }) : super(const BookingState());

  /// Fetch list
  Future<void> fetch({
    int? hotelId,
    int? customerId,
    String? bookingStatus,
  }) async {
    try {
      emit(state.copyWith(status: BookingStatusState.loading));
      final items = await getBookings.call(
        hotelId: hotelId,
        customerId: customerId,
        bookingStatus: bookingStatus,
      );
      emit(state.copyWith(
        status: BookingStatusState.success,
        items: items,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: BookingStatusState.failure,
        errorMessage: e.message,
      ));
    }
  }

  /// Create
  Future<void> add(BookingCreateRequest dto) async {
    try {
      emit(state.copyWith(status: BookingStatusState.loading));
      final created = await createBooking.call(dto);
      final list = [...?state.items, created];
      emit(state.copyWith(
        status: BookingStatusState.success,
        items: list,
        selected: created,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: BookingStatusState.failure,
        errorMessage: e.message,
      ));
    }
  }

  /// Confirm
  Future<void> confirm(int id) async {
    await _updateStatus(() => confirmBooking.call(id));
  }

  /// Cancel
  Future<void> cancel(int id) async {
    await _updateStatus(() => cancelBooking.call(id));
  }

  /// Complete
  Future<void> complete(int id) async {
    await _updateStatus(() => completeBooking.call(id));
  }

  Future<void> _updateStatus(Future<BookingEntity> Function() action) async {
    try {
      emit(state.copyWith(status: BookingStatusState.loading));
      final updated = await action();
      final list =
          state.items?.map((e) => e.id == updated.id ? updated : e).toList();
      emit(state.copyWith(
        status: BookingStatusState.success,
        items: list,
        selected: updated,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: BookingStatusState.failure,
        errorMessage: e.message,
      ));
    }
  }

  void markPaymentPaid(int bookingId, {String? paidAt}) {
    final list = state.items?.map((e) {
      if (e.id != bookingId) return e;
      return BookingEntity(
        id: e.id,
        checkinDate: e.checkinDate,
        checkoutDate: e.checkoutDate,
        bookingStatus: e.bookingStatus,
        paymentMethod: e.paymentMethod,
        paymentStatus: 'PAID',
        paymentExpireAt: e.paymentExpireAt,
        paidAt: paidAt ?? DateTime.now().toIso8601String(),
        hotel: e.hotel,
        customer: e.customer,
        bookingRooms: e.bookingRooms,
        bookingServices: e.bookingServices,
        totalAmount: e.totalAmount,
        note: e.note,
        onCreate: e.onCreate,
        onUpdate: e.onUpdate,
      );
    }).toList();

    emit(state.copyWith(items: list));
  }
}
