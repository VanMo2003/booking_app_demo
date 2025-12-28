import 'package:booking_app_mobile/core/api/dio_client.dart';
import 'package:booking_app_mobile/features/position/data/mapper/position_mapper.dart';
import 'package:booking_app_mobile/features/position/data/models/request/position_create_dto.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entity/position.dart';
import '../../domain/repositories/position_repository.dart';
import '../datasource/remote/position_api_service.dart';
import '../models/request/position_update_dto.dart';
import '../models/response/position_response.dart';

@LazySingleton(as: PositionRepository)
class PositionRepositoryImpl implements PositionRepository {
  final PositionApiService apiService;
  final DioClient dioClient;

  PositionRepositoryImpl(this.apiService, this.dioClient);

  @override
  Future<List<Position>> getPositions() async {
    try {
      final response = await apiService.getPosition();

      List<Position>? items;
      items ??= [];

      for (var item in response.data) {
        items.add(PositionMapper.toEntity(PositionResponse.fromJson(item)));
      }

      return items;
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<Position> createPosition(PositionCreateDto position) async {
    try {
      final response = await apiService.createPosition(position);
      final data = response.data;
      return PositionMapper.toEntity(PositionResponse.fromJson(data));
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<Position> updatePosition(PositionUpdateDto position) async {
    try {
      final response =
          await apiService.updatePosition(position.id ?? 0, position);
      final data = response.data;
      return PositionMapper.toEntity(PositionResponse.fromJson(data));
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<void> deletePosition(int id) async {
    try {
      await apiService.deletePosition(id);
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }
}
