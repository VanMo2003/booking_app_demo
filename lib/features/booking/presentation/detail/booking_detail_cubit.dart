import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/booking_usecases.dart';

class BookingDetailState extends Equatable {
  const BookingDetailState({this.booking = const LoadState()});

  final LoadState<Booking> booking;

  @override
  List<Object?> get props => [booking];
}

@injectable
class BookingDetailCubit extends Cubit<BookingDetailState> {
  BookingDetailCubit(this._getBooking, this._changeStatus, this._changePaymentMethod, this._deleteBooking)
      : super(const BookingDetailState());

  final GetBooking _getBooking;
  final ChangeBookingStatus _changeStatus;
  final ChangePaymentMethod _changePaymentMethod;
  final DeleteBooking _deleteBooking;
  late int _bookingId;

  Future<void> load(int bookingId) {
    _bookingId = bookingId;
    emit(BookingDetailState(booking: state.booking.toLoading()));
    return refresh();
  }

  Future<void> refresh() async {
    try {
      final booking = await _getBooking(_bookingId);
      if (!isClosed) emit(BookingDetailState(booking: state.booking.toSuccess(booking)));
    } catch (error) {
      if (!isClosed) {
        emit(BookingDetailState(booking: state.booking.toError(error)));
      }
    }
  }

  Future<ActionResult<Booking>> perform(BookingAction action) async {
    final result = await runAction(() => _changeStatus(_bookingId, action));
    if (result.isSuccess && !isClosed) {
      // Response chuyển trạng thái đã đủ dữ liệu; đọc lại để chắc chắn đồng bộ.
      emit(BookingDetailState(booking: state.booking.toSuccess(result.value!)));
      await refresh();
    }
    return result;
  }

  Future<ActionResult<Booking>> changePaymentMethod(PaymentMethod method) async {
    final result = await runAction(() => _changePaymentMethod(_bookingId, method));
    if (result.isSuccess && !isClosed) {
      emit(BookingDetailState(booking: state.booking.toSuccess(result.value!)));
    }
    return result;
  }

  Future<ActionResult<void>> delete() => runAction(() => _deleteBooking(_bookingId));
}
