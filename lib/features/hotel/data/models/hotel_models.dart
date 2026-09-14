import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/json_reader.dart';
import '../../../amenity/data/models/amenity_models.dart';
import '../../../room/data/models/room_models.dart';
import '../../../service/data/models/hotel_service_models.dart';
import '../../domain/entities/hotel.dart';

/// JSON `ListHotelResponse` / `HotelDetailResponse` ↔ [Hotel] / [HotelDetail].
abstract final class HotelModel {
  static Hotel fromJson(Json json) => Hotel(
        id: json.integer('id'),
        name: json.str('name'),
        address: json.str('address'),
        phone: json.str('phone'),
        description: json.str('description'),
        category: json.str('category'),
        rating: json.integer('rating'),
        pathImage: json.strOrNull('pathImage'),
        active: json.flag('active', true),
        status: HotelStatus.tryParse(json.strOrNull('status')),
        accountId: json.strOrNull('accountId'),
        hotelChainId: json.intOrNull('hotelChainId'),
        amenities: json.listOf('amenities', AmenityModel.fromJson),
        services: json.listOf('services', HotelServiceModel.fromJson),
      );

  /// Bản gọn để lưu kèm phiên đăng nhập.
  static Json toJson(Hotel hotel) => {
        'id': hotel.id,
        'name': hotel.name,
        'address': hotel.address,
        'phone': hotel.phone,
        'description': hotel.description,
        'category': hotel.category,
        'rating': hotel.rating,
        'pathImage': hotel.pathImage,
        'active': hotel.active,
        'accountId': hotel.accountId,
        'hotelChainId': hotel.hotelChainId,
      };

  static HotelDetail detailFromJson(Json json) => HotelDetail(
        hotel: fromJson(json),
        images: json.strings('images'),
        rooms: json.listOf('rooms', RoomModel.fromJson),
      );
}

class HotelCreateRequest {
  const HotelCreateRequest({
    required this.name,
    required this.address,
    required this.phone,
    required this.category,
    required this.accountId,
    required this.hotelChainId,
    this.description = '',
    this.active = true,
  });

  final String name;
  final String address;
  final String phone;
  final String category;

  /// Tài khoản HOTEL_MANAGER được giao cơ sở.
  final String accountId;
  final int hotelChainId;
  final String description;
  final bool active;

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'phone': phone,
        'category': category,
        'description': description,
        'active': active,
        'accountId': accountId,
        'hotelChainId': hotelChainId,
      };
}

class HotelUpdateRequest {
  const HotelUpdateRequest({
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
    required this.category,
    required this.pathImage,
    required this.active,
  });

  /// Luôn gửi đủ trường: thiếu `active` BE sẽ đóng cơ sở, thiếu ảnh bìa sẽ mất ảnh.
  factory HotelUpdateRequest.fromHotel(
    Hotel hotel, {
    bool? active,
    String? pathImage,
  }) =>
      HotelUpdateRequest(
        name: hotel.name,
        address: hotel.address,
        phone: hotel.phone,
        description: hotel.description,
        category: hotel.category,
        pathImage: pathImage ?? hotel.pathImage,
        active: active ?? hotel.active,
      );

  final String name;
  final String address;
  final String phone;
  final String description;
  final String category;
  final String? pathImage;
  final bool active;

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'phone': phone,
        'description': description,
        'category': category,
        'pathImage': pathImage,
        'active': active,
      };
}
