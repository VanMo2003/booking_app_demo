import 'package:booking_app_mobile/features/hotel/data/mapper/hotel_service_mapper.dart';
import 'package:booking_app_mobile/features/hotel/data/models/hotel_response.dart';
import 'package:booking_app_mobile/features/hotel/domain/entities/hotel.dart';

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
        active: dto.active ?? false,
        accountId: "",
        amenities: [],
        services: dto.services != null
            ? dto.services!
                .map(
                  (service) => HotelServiceMapper.toEntity(
                    service,
                  ),
                )
                .toList()
            : []);
  }
}
