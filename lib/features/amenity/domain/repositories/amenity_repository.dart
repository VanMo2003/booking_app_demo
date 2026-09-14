import '../../data/models/amenity_models.dart';
import '../entities/amenity.dart';

abstract interface class AmenityRepository {
  Future<List<Amenity>> commonByHotel(int hotelId);

  Future<List<Amenity>> byRoom({required int hotelId, required int roomId});

  Future<Amenity> create(AmenityCreateRequest request);

  Future<Amenity> update(int id, AmenityUpdateRequest request);

  Future<void> delete(int id);

  Future<void> linkToRoom({required int roomId, required int amenityId});
}
