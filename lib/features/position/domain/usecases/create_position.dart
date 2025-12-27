import 'package:booking_app_mobile/features/position/data/models/request/position_create_dto.dart';

import '../../domain/entity/position.dart';
import '../repositories/position_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreatePosition {
  final PositionRepository repository;

  CreatePosition(this.repository);

  Future<Position> call(PositionCreateDto position) async {
    return await repository.createPosition(position);
  }
}
