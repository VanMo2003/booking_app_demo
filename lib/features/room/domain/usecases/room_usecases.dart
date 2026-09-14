import 'package:injectable/injectable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/upload_file.dart';
import '../../data/models/room_models.dart';
import '../entities/room.dart';
import '../repositories/room_repository.dart';

@injectable
class GetBranchRooms {
  const GetBranchRooms(this._repository);

  final RoomRepository _repository;

  Future<List<Room>> call(int hotelId) => _repository.getRooms(hotelId);
}

@injectable
class GetRoomDetail {
  const GetRoomDetail(this._repository);

  final RoomRepository _repository;

  Future<RoomDetail> call(int id) => _repository.getRoom(id);
}

/// Phòng của cơ sở kèm trạng thái tính theo khoảng ngày.
@injectable
class GetRoomsForDates {
  const GetRoomsForDates(this._repository);

  final RoomRepository _repository;

  Future<List<Room>> call({
    required int hotelId,
    required DateTime checkin,
    required DateTime checkout,
  }) =>
      _repository.available(hotelId: hotelId, checkin: checkin, checkout: checkout);
}

@injectable
class SaveRoom {
  const SaveRoom(this._repository);

  final RoomRepository _repository;

  /// [id] rỗng → tạo mới.
  Future<Room> call(RoomRequest request, {int? id}) =>
      id == null ? _repository.create(request) : _repository.update(id, request);
}

@injectable
class SetRoomStatus {
  const SetRoomStatus(this._repository);

  final RoomRepository _repository;

  Future<Room> call(Room room, RoomStatus status) =>
      _repository.update(room.id, RoomRequest.fromRoom(room, status: status));
}

@injectable
class DeleteRoom {
  const DeleteRoom(this._repository);

  final RoomRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}

@injectable
class UploadRoomImages {
  const UploadRoomImages(this._repository);

  final RoomRepository _repository;

  Future<List<String>> call(int id, List<UploadFile> images) =>
      _repository.uploadImages(id, images);
}
