import 'package:equatable/equatable.dart';

import '../../../domain/entities/hotel.dart';

enum HotelDetailStatus { initial, loading, success, failure }

class HotelDetailState extends Equatable {
  final HotelDetailStatus status;
  final Hotel? hotel;
  final String? errorMessage;

  const HotelDetailState({
    required this.status,
    this.hotel,
    this.errorMessage,
  });

  factory HotelDetailState.initial() => const HotelDetailState(
        status: HotelDetailStatus.initial,
      );

  HotelDetailState copyWith({
    HotelDetailStatus? status,
    Hotel? hotel,
    String? errorMessage,
  }) {
    return HotelDetailState(
      status: status ?? this.status,
      hotel: hotel ?? this.hotel,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, hotel, errorMessage];
}
