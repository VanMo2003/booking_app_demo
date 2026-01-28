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
  Future<List<Room>> getAvailableRooms({
    required int hotelId,
    required String checkinDate,
    required String checkoutDate,
  });
  Future<Room> getRoomById({required int id});
  Future<Room> createRoom(Room room);
  Future<Room> updateRoom(Room room);
  Future<List<String>> uploadRoomImages(
      {required int roomId, required List<String> filePaths});
  Future<void> deleteRoom(int id);
}
