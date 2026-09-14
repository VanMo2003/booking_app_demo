import '../../data/models/hotel_service_models.dart';
import '../entities/hotel_service.dart';

abstract interface class HotelServiceRepository {
  Future<List<HotelService>> byHotel(int hotelId);

  Future<HotelService> create(ServiceRequest request);

  Future<HotelService> update(int id, ServiceRequest request);

  Future<void> delete(int id);
}
