import '../repositories/room_type_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteRoomType {
  final RoomTypeRepository repository;

  DeleteRoomType(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteRoomType(id);
  }
}
