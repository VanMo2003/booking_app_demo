import '../../../../core/network/json_reader.dart';
import '../../domain/entities/amenity.dart';

/// JSON `AmenityResponse` ↔ [Amenity].
abstract final class AmenityModel {
  static Amenity fromJson(Json json) => Amenity(
        id: json.integer('id'),
        name: json.str('name'),
        description: json.str('description'),
        common: json.flag('common', true),
        active: json.flag('active', true),
        hotelName: json.strOrNull('hotelName'),
        roomName: json.strOrNull('roomName'),
      );
}

class AmenityCreateRequest {
  const AmenityCreateRequest({
    required this.name,
    required this.hotelId,
    this.description = '',
    this.common = true,
    this.roomId,
  });

  final String name;
  final int hotelId;
  final String description;
  final bool common;

  /// Chỉ gửi khi `common == false` — BE tự gắn tiện ích vào phòng này.
  final int? roomId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'common': common,
        'hotelId': hotelId,
        if (!common && roomId != null) 'roomId': roomId,
        'active': true,
      };
}

class AmenityUpdateRequest {
  const AmenityUpdateRequest({
    required this.name,
    required this.description,
    required this.common,
  });

  final String name;
  final String description;

  /// Luôn gửi: thiếu trường này BE sẽ đặt thành `false`.
  final bool common;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'common': common,
      };
}
