import 'package:injectable/injectable.dart';
import '../../../share/data/models/api_response.dart';
import '../../domain/entity/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasource/remote/room_api_service.dart';
import '../models/response/room_response.dart';
import '../models/request/room_create_dto.dart';
import '../models/request/room_update_dto.dart';

@LazySingleton(as: RoomRepository)
class RoomRepositoryImpl implements RoomRepository {
  final RoomApiService apiService;

  RoomRepositoryImpl(this.apiService);

  @override
  Future<Room> createRoom(Room room) async {
    final body = RoomCreateDto(
      roomNumber: room.roomNumber,
      price: room.price,
      description: room.description,
      capacity: room.capacity,
      hotelId: room.hotelId,
      roomTypeId: room.roomTypeId,
    );
    final ApiResponse response = await apiService.createRoom(body);
    return RoomResponse.fromJson(response.data).toEntity();
  }

  @override
  Future<void> deleteRoom(int id) async {
    await apiService.deleteRoom(id);
  }

  @override
  Future<Room> updateRoom(Room room) async {
    final id = room.id!;
    final body = RoomUpdateDto(
      roomNumber: room.roomNumber,
      price: room.price,
      description: room.description,
      capacity: room.capacity,
      roomTypeId: room.roomTypeId,
      status: room.status,
    );
    final ApiResponse response = await apiService.updateRoom(id, body);
    return RoomResponse.fromJson(response.data).toEntity();
  }

  @override
  Future<RoomList> getRooms(
      {required int hotelId, int page = 0, int size = 10}) async {
    final ApiResponse response = await apiService.getRooms(hotelId, page, size);
    final data = response.data as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;
    final items =
        content.map((e) => RoomResponse.fromJson(e).toEntity()).toList();
    return RoomList(
      content: items,
      page: data['page'] ?? page,
      size: data['size'] ?? size,
      totalElements: data['totalElements'] ?? items.length,
      totalPages: data['totalPages'] ?? 1,
    );
  }
}
