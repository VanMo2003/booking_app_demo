import 'package:booking_app_mobile/features/position/data/mapper/position_mapper.dart';
import 'package:booking_app_mobile/features/position/data/models/request/position_create_dto.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entity/position.dart';
import '../../domain/repositories/position_repository.dart';
import '../datasource/remote/position_api_service.dart';
import '../models/request/position_update_dto.dart';
import '../models/response/position_response.dart';

@LazySingleton(as: PositionRepository)
class PositionRepositoryImpl implements PositionRepository {
  final PositionApiService apiService;

  PositionRepositoryImpl(this.apiService);

  @override
  Future<List<Position>> getPositions() async {
    final response = await apiService.getPosition();

    List<Position>? items;
    items ??= [];

    for (var item in response.data) {
      items.add(PositionMapper.toEntity(PositionResponse.fromJson(item)));
    }

    return items;
  }

  @override
  Future<Position> createPosition(PositionCreateDto position) async {
    final body = position.toJson();
    final response = await apiService.createPosition(body);
    final data = response.data;
    return PositionMapper.toEntity(PositionResponse.fromJson(data));
  }

  @override
  Future<Position> updatePosition(PositionUpdateDto position) async {
    final id = position.id!;
    final body = {
      'name': position.name,
      'description': position.description,
    };
    final response = await apiService.updatePosition(id, body);
    final data = response.data;
    return PositionMapper.toEntity(PositionResponse.fromJson(data));
  }

  @override
  Future<void> deletePosition(int id) async {
    await apiService.deletePosition(id);
  }
}
