import '../../domain/entity/room_type.dart';

abstract class RoomTypeState {}

class RoomTypeInitial extends RoomTypeState {}

class RoomTypeLoading extends RoomTypeState {}

class RoomTypeLoaded extends RoomTypeState {
  final List<RoomType> items;

  RoomTypeLoaded(this.items);
}

class RoomTypeError extends RoomTypeState {
  final String message;

  RoomTypeError(this.message);
}
