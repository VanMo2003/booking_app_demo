import 'package:booking_app_mobile/features/amenity/data/models/amenity_response.dart';
import 'package:booking_app_mobile/features/amenity/domain/entity/amenity.dart';

class AmenityMapper {
  AmenityMapper._();

  static Amenity toEntity(AmenityResponse dto) {
    return Amenity(
        id: dto.id ?? 0,
        name: dto.name ?? "",
        description: dto.description ?? "",
        common: dto.common ?? true,
        active: dto.active ?? true);
  }
}
