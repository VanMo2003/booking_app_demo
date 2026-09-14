import '../../../../core/network/upload_file.dart';
import '../../data/models/room_models.dart';
import '../entities/room.dart';

abstract interface class RoomRepository {
  /// Toàn bộ phòng của cơ sở (gom mọi trang).
  Future<List<Room>> getRooms(int hotelId);

  Future<RoomDetail> getRoom(int id);

  Future<List<Room>> available({
    required int hotelId,
    required DateTime checkin,
    required DateTime checkout,
  });

  Future<Room> create(RoomRequest request);

  Future<Room> update(int id, RoomRequest request);

  Future<void> delete(int id);

  Future<List<String>> uploadImages(int id, List<UploadFile> images);
}
