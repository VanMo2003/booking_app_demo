import 'package:equatable/equatable.dart';
import '../../domain/entities/hotel.dart';

enum HotelStatus { initial, loading, success, failure }

class HotelState extends Equatable {
  final HotelStatus status;
  final List<Hotel> items;
  final int page;
  final int size;
  final bool hasMore;
  final String? errorMessage;
  final String? checkinDate;
  final String? checkoutDate;

  const HotelState({
    required this.status,
    required this.items,
    required this.page,
    required this.size,
    required this.hasMore,
    this.errorMessage,
    this.checkinDate,
    this.checkoutDate,
  });

  factory HotelState.initial() => const HotelState(
        status: HotelStatus.initial,
        items: [],
        page: 0,
        size: 10,
        hasMore: true,
      );

  HotelState copyWith({
    HotelStatus? status,
    List<Hotel>? items,
    int? page,
    int? size,
    bool? hasMore,
    String? errorMessage,
    String? checkinDate,
    String? checkoutDate,
  }) {
    return HotelState(
      status: status ?? this.status,
      items: items ?? this.items,
      page: page ?? this.page,
      size: size ?? this.size,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      checkinDate: checkinDate ?? this.checkinDate,
      checkoutDate: checkoutDate ?? this.checkoutDate,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        page,
        size,
        hasMore,
        errorMessage,
        checkinDate,
        checkoutDate,
      ];
}
