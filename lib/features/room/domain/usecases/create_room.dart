import 'package:injectable/injectable.dart';

import '../entity/room.dart';
import '../repositories/room_repository.dart';

@injectable
class CreateRoom {
  final RoomRepository repository;

  CreateRoom(this.repository);

  Future<Room> call(Room room) async => await repository.createRoom(room);
}
