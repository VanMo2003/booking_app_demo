import 'package:equatable/equatable.dart';
import '../../domain/entity/amenity.dart';

enum AmenityStatus { initial, loading, success, failure }

class AmenityState extends Equatable {
  final AmenityStatus status;
  final List<Amenity> items;
  final String? errorMessage;
  final Amenity? lastCreatedOrUpdated;
  final int? lastDeletedId;

  const AmenityState({
    required this.status,
    required this.items,
    this.errorMessage,
    this.lastCreatedOrUpdated,
    this.lastDeletedId,
  });

  factory AmenityState.initial() => const AmenityState(
        status: AmenityStatus.initial,
        items: [],
      );

  AmenityState copyWith({
    AmenityStatus? status,
    List<Amenity>? items,
    String? errorMessage,
    Amenity? lastCreatedOrUpdated,
    int? lastDeletedId,
    bool clearOneOff = false,
  }) {
    return AmenityState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      lastCreatedOrUpdated: clearOneOff ? null : (lastCreatedOrUpdated ?? this.lastCreatedOrUpdated),
      lastDeletedId: clearOneOff ? null : (lastDeletedId ?? this.lastDeletedId),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, lastCreatedOrUpdated, lastDeletedId];
}
