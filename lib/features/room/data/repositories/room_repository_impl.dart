import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/upload_file.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_api.dart';
import '../models/room_models.dart';

@LazySingleton(as: RoomRepository)
class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._api);

  final RoomApi _api;

  @override
  Future<List<Room>> getRooms(int hotelId) async {
    const size = AppConstants.bulkPageSize;
    final first = (await _api.byHotel(hotelId, 0, size)).parsePage(RoomModel.fromJson);
    final rooms = [...first.items];
    for (var page = 1; page < first.totalPages; page++) {
      rooms.addAll(
        (await _api.byHotel(hotelId, page, size)).parsePage(RoomModel.fromJson).items,
      );
    }
    rooms.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
    return rooms;
  }

  @override
  Future<RoomDetail> getRoom(int id) async =>
      (await _api.getById(id)).parse(RoomModel.detailFromJson);

  @override
  Future<List<Room>> available({
    required int hotelId,
    required DateTime checkin,
    required DateTime checkout,
  }) async {
    final rooms = (await _api.available(
      hotelId,
      Fmt.apiDate(checkin),
      Fmt.apiDate(checkout),
    ))
        .parseList(RoomModel.fromJson);
    return rooms..sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
  }

  @override
  Future<Room> create(RoomRequest request) async =>
      (await _api.create(request.toJson())).parse(RoomModel.fromJson);

  @override
  Future<Room> update(int id, RoomRequest request) async =>
      (await _api.update(id, request.toJson())).parse(RoomModel.fromJson);

  @override
  Future<void> delete(int id) async => (await _api.delete(id)).ensureSuccess();

  @override
  Future<List<String>> uploadImages(int id, List<UploadFile> images) async =>
      (await _api.uploadImages(
        id,
        images.map((image) => image.toMultipart()).toList(),
      ))
          .stringList;
}
