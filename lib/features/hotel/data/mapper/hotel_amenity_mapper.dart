import 'package:booking_app_mobile/features/hotel/data/models/hotel_response.dart';

import '../../domain/entities/hotel.dart';

class HotelAmenityMapper {
  HotelAmenityMapper._();

  static HotelAmenity toEntity(HotelAmenitieResponse dto) {
    return HotelAmenity(
      id: dto.id ?? 0,
      name: dto.name ?? "",
      description: dto.description ?? "",
      active: dto.active ?? false,
      common: dto.common ?? false,
      onCreate: dto.onCreate ?? "",
      onUpdate: dto.onUpdate ?? "",
    );
  }
}
