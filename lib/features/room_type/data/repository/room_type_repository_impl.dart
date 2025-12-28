import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:booking_app_mobile/core/api/dio_client.dart';

import '../../domain/entity/room_type.dart';
import '../../domain/repositories/room_type_repository.dart';
import '../datasource/remote/room_type_api_service.dart';
import '../models/response/room_type_response.dart';
import '../models/request/room_type_create_dto.dart';
import '../models/request/room_type_update_dto.dart';
import '../../../../features/share/data/models/api_response.dart';

@LazySingleton(as: RoomTypeRepository)
class RoomTypeRepositoryImpl implements RoomTypeRepository {
  final RoomTypeApiService apiService;
  final DioClient dioClient;

  RoomTypeRepositoryImpl(this.apiService, this.dioClient);

  @override
  Future<List<RoomType>> getRoomTypes() async {
    try {
      final ApiResponse response = await apiService.getRoomTypes();
      final List<RoomType> items = [];
      for (var item in response.data) {
        items.add(RoomTypeResponse.fromJson(item).toEntity());
      }
      return items;
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<RoomType> createRoomType(RoomType roomType) async {
    try {
      final body = RoomTypeCreateDto(
        name: roomType.name,
        description: roomType.description,
      );
      final response = await apiService.createRoomType(body);
      return RoomTypeResponse.fromJson(response.data).toEntity();
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<RoomType> updateRoomType(RoomType roomType) async {
    try {
      final id = roomType.id!;
      final body = RoomTypeUpdateDto(
        id: id,
        name: roomType.name,
        description: roomType.description,
      );
      final response = await apiService.updateRoomType(id, body);
      return RoomTypeResponse.fromJson(response.data).toEntity();
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<void> deleteRoomType(int id) async {
    try {
      await apiService.deleteRoomType(id);
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }
}
