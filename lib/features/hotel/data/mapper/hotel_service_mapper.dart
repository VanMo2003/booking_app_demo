import 'package:booking_app_mobile/features/hotel/data/models/hotel_service_response.dart';
import 'package:booking_app_mobile/features/hotel/domain/entities/service.dart';

class HotelServiceMapper {
  HotelServiceMapper._();

  static HotelService toEntity(HotelServicesResponse dto) {
    return HotelService(
        id: dto.id ?? 0, name: dto.name ?? "", unitPrice: dto.unitPrice ?? 0, description: dto.description ?? "");
  }
}
