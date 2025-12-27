import '../repositories/room_type_repository.dart';
import '../../domain/entity/room_type.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetRoomTypes {
  final RoomTypeRepository repository;

  GetRoomTypes(this.repository);

  Future<List<RoomType>> call() async => await repository.getRoomTypes();
}
