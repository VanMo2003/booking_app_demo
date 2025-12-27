import '../../domain/entity/room_type.dart';
import '../repositories/room_type_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateRoomType {
  final RoomTypeRepository repository;

  UpdateRoomType(this.repository);

  Future<RoomType> call(RoomType roomType) async {
    return await repository.updateRoomType(roomType);
  }
}
