import 'package:equatable/equatable.dart';

import '../../data/models/request/amenity_create_request.dart';
import '../../data/models/request/amenity_update_request.dart';

sealed class AmenityEvent extends Equatable {
  const AmenityEvent();
  @override
  List<Object?> get props => [];
}

class AmenitiesByHotelFetched extends AmenityEvent {
  final int hotelId;
  const AmenitiesByHotelFetched(this.hotelId);
  @override
  List<Object?> get props => [hotelId];
}

class AmenitiesByRoomFetched extends AmenityEvent {
  final int hotelId;
  final int roomId;
  const AmenitiesByRoomFetched({required this.hotelId, required this.roomId});
  @override
  List<Object?> get props => [hotelId, roomId];
}

class AmenityCreated extends AmenityEvent {
  final AmenityCreateRequest request;
  const AmenityCreated(this.request);
  @override
  List<Object?> get props => [request];
}

class AmenityUpdated extends AmenityEvent {
  final int id;
  final AmenityUpdateRequest request;
  const AmenityUpdated({required this.id, required this.request});
  @override
  List<Object?> get props => [id, request];
}

class AmenityDeleted extends AmenityEvent {
  final int id;
  const AmenityDeleted(this.id);
  @override
  List<Object?> get props => [id];
}
