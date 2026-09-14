import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/bloc/load_state.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/text_search.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/booking_usecases.dart';

enum DeskFilter { arrivals, departures, inHouse, pending, all }

class DeskState extends Equatable {
  const DeskState({
    this.bookings = const LoadState(),
    this.filter = DeskFilter.arrivals,
    this.query = '',
  });

  final LoadState<List<Booking>> bookings;
  final DeskFilter filter;
  final String query;

  /// BE bỏ qua `bookingStatus` khi lọc theo cơ sở, nên mọi bộ lọc chạy ở FE.
  static bool matchesFilter(Booking booking, DeskFilter filter, DateTime today) =>
      switch (filter) {
        DeskFilter.arrivals =>
          DateOnly.isSameDay(booking.checkinDate, today) && booking.status.isOpen,
        DeskFilter.departures => DateOnly.isSameDay(booking.checkoutDate, today) &&
            booking.status == BookingStatus.confirmed,
        DeskFilter.inHouse => booking.status == BookingStatus.confirmed &&
            DateOnly.isWithinStay(today, booking.checkinDate, booking.checkoutDate),
        DeskFilter.pending => booking.status.canConfirm,
        DeskFilter.all => true,
      };

  bool _matchesQuery(Booking booking) {
    final text = query.trim();
    if (text.isEmpty) return true;
    final digits = text.replaceAll('#', '');
    return TextSearch.matches(booking.customer?.fullName ?? '', text) ||
        (booking.customer?.phoneNumber ?? '').contains(digits) ||
        booking.id.toString() == digits;
  }

  List<Booking> get visible {
    final today = DateOnly.today();
    return (bookings.data ?? const <Booking>[])
        .where((b) => matchesFilter(b, filter, today) && _matchesQuery(b))
        .toList();
  }

  int count(DeskFilter value) {
    final today = DateOnly.today();
    return (bookings.data ?? const <Booking>[])
        .where((b) => matchesFilter(b, value, today))
        .length;
  }

  DeskState copyWith({
    LoadState<List<Booking>>? bookings,
    DeskFilter? filter,
    String? query,
  }) =>
      DeskState(
        bookings: bookings ?? this.bookings,
        filter: filter ?? this.filter,
        query: query ?? this.query,
      );

  @override
  List<Object?> get props => [bookings, filter, query];
}

@injectable
class DeskCubit extends Cubit<DeskState> {
  DeskCubit(this._getBookings) : super(const DeskState());

  final GetBranchBookings _getBookings;
  late int _hotelId;

  Future<void> start(int hotelId) {
    _hotelId = hotelId;
    return load();
  }

  Future<void> load() async {
    emit(state.copyWith(bookings: state.bookings.toLoading()));
    try {
      final bookings = await _getBookings(_hotelId);
      if (!isClosed) emit(state.copyWith(bookings: state.bookings.toSuccess(bookings)));
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(bookings: state.bookings.toFailure(AppException.from(error).message)));
      }
    }
  }

  void setFilter(DeskFilter filter) => emit(state.copyWith(filter: filter));

  void setQuery(String query) => emit(state.copyWith(query: query));
}
