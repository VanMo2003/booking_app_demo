import '../../domain/entity/room_type.dart';
import '../repositories/room_type_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateRoomType {
  final RoomTypeRepository repository;

  CreateRoomType(this.repository);

  Future<RoomType> call(RoomType roomType) async {
    return await repository.createRoomType(roomType);
  }
}
