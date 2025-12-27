import 'package:injectable/injectable.dart';

import '../entity/room.dart';
import '../repositories/room_repository.dart';

@injectable
class UpdateRoom {
  final RoomRepository repository;

  UpdateRoom(this.repository);

  Future<Room> call(Room room) async => await repository.updateRoom(room);
}
