import '../../data/models/request/position_update_dto.dart';
import '../../domain/entity/position.dart';
import '../repositories/position_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdatePosition {
  final PositionRepository repository;

  UpdatePosition(this.repository);

  Future<Position> call(PositionUpdateDto position) async {
    return await repository.updatePosition(position);
  }
}
