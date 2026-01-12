import 'package:booking_app_mobile/features/hotel/data/models/hotel_response.dart';

import '../../domain/entities/hotel.dart';

class HotelRoomMapper {
  HotelRoomMapper._();

  static HotelRoom toEntity(HotelRoomResponse dto) {
    return HotelRoom(
      id: dto.id ?? 0,
      pathImage: dto.pathImage ?? "",
      capacity: dto.capacity ?? 0,
      price: dto.price ?? 0,
      roomNumber: dto.roomNumber ?? "",
      roomTypeId: dto.roomTypeId ?? 0,
      roomTypeName: dto.roomTypeName ?? "",
      status: dto.status ?? "",
      hotelId: dto.hotelId ?? 0,
      hotelName: dto.hotelName ?? "",
      description: dto.description ?? "",
      onCreate: dto.onCreate ?? "",
      onUpdate: dto.onUpdate ?? "",
    );
  }
}
