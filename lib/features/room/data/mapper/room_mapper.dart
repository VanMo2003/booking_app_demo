import '../../domain/entity/room.dart';
import '../models/request/room_create_dto.dart';
import '../models/request/room_update_dto.dart';

class RoomMapper {
  RoomMapper._();

  static RoomCreateDto toCreate(Room r) => RoomCreateDto(
        roomNumber: r.roomNumber,
        price: r.price,
        description: r.description,
        capacity: r.capacity,
        hotelId: r.hotelId,
        roomTypeId: r.roomTypeId,
      );

  static RoomUpdateDto toUpdate(Room r) => RoomUpdateDto(
        roomNumber: r.roomNumber,
        price: r.price,
        description: r.description,
        capacity: r.capacity,
        roomTypeId: r.roomTypeId,
        status: r.status,
      );
}
