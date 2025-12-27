import 'package:injectable/injectable.dart';

import '../entity/position.dart';
import '../repositories/position_repository.dart';

@injectable
class GetPositions {
  final PositionRepository repository;

  GetPositions(this.repository);

  Future<List<Position>> call() async {
    return await repository.getPositions();
  }
}
