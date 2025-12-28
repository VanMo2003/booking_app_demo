import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:booking_app_mobile/core/api/dio_client.dart';
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
  final DioClient dioClient;

  RoomRepositoryImpl(this.apiService, this.dioClient);

  @override
  Future<Room> createRoom(Room room) async {
    try {
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
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<void> deleteRoom(int id) async {
    try {
      await apiService.deleteRoom(id);
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<Room> updateRoom(Room room) async {
    try {
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
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<RoomList> getRooms(
      {required int hotelId, int page = 0, int size = 10}) async {
    try {
      final ApiResponse response =
          await apiService.getRooms(hotelId, page, size);
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
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }
}
