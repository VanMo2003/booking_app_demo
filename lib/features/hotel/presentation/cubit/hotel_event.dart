import 'package:equatable/equatable.dart';

sealed class HotelEvent extends Equatable {
  const HotelEvent();
  @override
  List<Object?> get props => [];
}

class HotelsFetched extends HotelEvent {
  final int page;
  final int size;
  final bool refresh;
  final String? checkinDate;
  final String? checkoutDate;

  const HotelsFetched({
    required this.page,
    required this.size,
    this.refresh = false,
    this.checkinDate,
    this.checkoutDate,
  });

  @override
  List<Object?> get props => [page, size, refresh, checkinDate, checkoutDate];
}
