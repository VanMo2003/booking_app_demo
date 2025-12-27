import '../repositories/position_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeletePosition {
  final PositionRepository repository;

  DeletePosition(this.repository);

  Future<void> call(int id) async {
    return await repository.deletePosition(id);
  }
}
