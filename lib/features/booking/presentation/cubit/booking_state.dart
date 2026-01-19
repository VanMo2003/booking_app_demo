part of 'booking_cubit.dart';

enum BookingStatusState { initial, loading, success, failure }

extension BookingStatusStateX on BookingStatusState {
  bool get isLoading => this == BookingStatusState.loading;
  bool get isSuccess => this == BookingStatusState.success;
  bool get isFailure => this == BookingStatusState.failure;
}

@freezed
class BookingState with _$BookingState {
  const factory BookingState({
    @Default(BookingStatusState.initial) BookingStatusState status,
    List<BookingEntity>? items,
    BookingEntity? selected,
    String? errorMessage,
  }) = _BookingState;
}
