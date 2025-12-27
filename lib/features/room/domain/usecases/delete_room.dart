import 'package:injectable/injectable.dart';

import '../repositories/room_repository.dart';

@injectable
class DeleteRoom {
  final RoomRepository repository;

  DeleteRoom(this.repository);

  Future<void> call(int id) async => await repository.deleteRoom(id);
}
