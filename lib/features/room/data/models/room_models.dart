import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/json_reader.dart';
import '../../../amenity/data/models/amenity_models.dart';
import '../../domain/entities/room.dart';

/// JSON `RoomResponse` / `RoomDetailResponse` ↔ [Room] / [RoomDetail].
abstract final class RoomModel {
  static Room fromJson(Json json) => Room(
        id: json.integer('id'),
        roomNumber: json.str('roomNumber'),
        price: json.decimal('price'),
        pathImage: json.strOrNull('pathImage'),
        description: json.str('description'),
        capacity: json.integer('capacity', 1),
        status: RoomStatus.parse(json.strOrNull('status')),
        hotelId: json.intOrNull('hotelId'),
        hotelName: json.strOrNull('hotelName'),
        roomTypeId: json.intOrNull('roomTypeId'),
        roomTypeName: json.str('roomTypeName'),
      );

  static RoomDetail detailFromJson(Json json) => RoomDetail(
        room: fromJson(json),
        images: json.strings('images'),
        amenities: json.listOf('amenities', AmenityModel.fromJson),
      );
}

class RoomRequest {
  const RoomRequest({
    required this.roomNumber,
    required this.price,
    required this.capacity,
    required this.roomTypeId,
    this.description = '',
    this.status = RoomStatus.available,
    this.hotelId,
  });

  final String roomNumber;
  final double price;
  final int capacity;
  final int roomTypeId;
  final String description;
  final RoomStatus status;

  /// Chỉ gửi khi tạo mới.
  final int? hotelId;

  factory RoomRequest.fromRoom(Room room, {RoomStatus? status}) => RoomRequest(
        roomNumber: room.roomNumber,
        price: room.price,
        capacity: room.capacity,
        roomTypeId: room.roomTypeId ?? 0,
        description: room.description,
        status: status ?? room.status,
      );

  Map<String, dynamic> toJson() => {
        'roomNumber': roomNumber,
        'price': price.round(),
        'description': description,
        'capacity': capacity,
        'roomTypeId': roomTypeId,
        'status': status.value,
        if (hotelId != null) 'hotelId': hotelId,
      };
}
