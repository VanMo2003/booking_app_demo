import '../../domain/entities/hotel.dart';
import '../models/hotel_response.dart';

class HotelServiceMapper {
  HotelServiceMapper._();

  static HotelService toEntity(HotelServicesResponse dto) {
    return HotelService(
      id: dto.id ?? 0,
      name: dto.name ?? "",
      unitPrice: dto.unitPrice ?? 0,
      description: dto.description ?? "",
      onCreate: dto.onCreate ?? "",
      onUpdate: dto.onUpdate ?? "",
    );
  }
}
