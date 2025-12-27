import '../entity/room_type.dart';

abstract class RoomTypeRepository {
  Future<List<RoomType>> getRoomTypes();
  Future<RoomType> createRoomType(RoomType roomType);
  Future<RoomType> updateRoomType(RoomType roomType);
  Future<void> deleteRoomType(int id);
}
