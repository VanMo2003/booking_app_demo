import '../../../../core/network/json_reader.dart';
import '../../domain/entities/hotel_service.dart';

/// JSON `ServiceResponse` ↔ [HotelService].
abstract final class HotelServiceModel {
  static HotelService fromJson(Json json) => HotelService(
        id: json.integer('id'),
        name: json.str('name'),
        unitPrice: json.decimal('unitPrice'),
        description: json.str('description'),
      );
}

class ServiceRequest {
  const ServiceRequest({
    required this.name,
    required this.unitPrice,
    this.description = '',
    this.hotelId,
  });

  final String name;
  final double unitPrice;
  final String description;

  /// Chỉ cần khi tạo mới.
  final int? hotelId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'unitPrice': unitPrice.round(),
        'description': description,
        if (hotelId != null) 'hotelId': hotelId,
      };
}
