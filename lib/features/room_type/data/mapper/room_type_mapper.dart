import '../../domain/entity/room_type.dart';
import '../models/request/room_type_create_dto.dart';
import '../models/request/room_type_update_dto.dart';

class RoomTypeMapper {
  RoomTypeMapper._();

  static RoomTypeCreateDto toCreate(RoomType rt) =>
      RoomTypeCreateDto(name: rt.name, description: rt.description);

  static RoomTypeUpdateDto toUpdate(RoomType rt) =>
      RoomTypeUpdateDto(id: rt.id, name: rt.name, description: rt.description);
}
