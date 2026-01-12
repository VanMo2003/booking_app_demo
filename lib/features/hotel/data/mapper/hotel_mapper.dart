import 'package:booking_app_mobile/features/hotel/data/mapper/hotel_amenity_mapper.dart';
import 'package:booking_app_mobile/features/hotel/data/mapper/hotel_service_mapper.dart';
import 'package:booking_app_mobile/features/hotel/data/models/hotel_response.dart';
import 'package:booking_app_mobile/features/hotel/domain/entities/hotel.dart';

import 'hotel_room_mapper.dart';

class HotelMapper {
  HotelMapper._();

  static Hotel toEntity(HotelResponse dto) {
    return Hotel(
      id: dto.id ?? 0,
      name: dto.name ?? "",
      address: dto.address ?? "",
      phone: dto.phone ?? "",
      description: dto.description ?? "",
      category: dto.category ?? "",
      rating: dto.rating ?? 0,
      pathImage: dto.pathImage ?? "",
      images: dto.images ?? [],
      active: dto.active ?? false,
      accountId: dto.accountId ?? "",
      rooms: dto.rooms != null
          ? dto.rooms!
              .map(
                (room) => HotelRoomMapper.toEntity(
                  room,
                ),
              )
              .toList()
          : [],
      amenities: dto.amenities != null
          ? dto.amenities!
              .map(
                (amenity) => HotelAmenityMapper.toEntity(
                  amenity,
                ),
              )
              .toList()
          : [],
      services: dto.services != null
          ? dto.services!
              .map(
                (service) => HotelServiceMapper.toEntity(
                  service,
                ),
              )
              .toList()
          : [],
      onCreate: dto.onCreate ?? "",
      onUpdate: dto.onUpdate ?? "",
    );
  }
}
