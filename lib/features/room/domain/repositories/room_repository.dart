import '../entity/room.dart';

class RoomList {
  final List<Room> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  RoomList({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });
}

abstract class RoomRepository {
  Future<RoomList> getRooms(
      {required int hotelId, int page = 0, int size = 10});
  Future<Room> getRoomById({required int id});
  Future<Room> createRoom(Room room);
  Future<Room> updateRoom(Room room);
  Future<void> deleteRoom(int id);
}
