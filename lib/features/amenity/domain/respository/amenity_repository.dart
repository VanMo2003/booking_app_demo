import '../../data/models/request/amenity_create_request.dart';
import '../../data/models/request/amenity_update_request.dart';
import '../entity/amenity.dart';

abstract class AmenityRepository {
  Future<Amenity> create(AmenityCreateRequest req);
  Future<Amenity> update(int id, AmenityUpdateRequest req);
  Future<List<Amenity>> getByHotel(int hotelId);
  Future<List<Amenity>> getByRoom({required int hotelId, required int roomId});
  Future<void> delete(int id);
}
