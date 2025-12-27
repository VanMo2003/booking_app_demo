import 'package:booking_app_mobile/features/position/data/models/request/position_create_dto.dart';

import '../../data/models/request/position_update_dto.dart';
import '../entity/position.dart';

abstract class PositionRepository {
  Future<List<Position>> getPositions();
  Future<Position> createPosition(PositionCreateDto request);
  Future<Position> updatePosition(PositionUpdateDto request);
  Future<void> deletePosition(int id);
}
