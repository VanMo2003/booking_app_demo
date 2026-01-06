import 'package:booking_app_mobile/features/amenity/domain/entity/amenity.dart';
import 'package:booking_app_mobile/features/amenity/domain/respository/amenity_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class GetAmenityByRoom {
  final AmenityRepository repository;

  GetAmenityByRoom(this.repository);

  Future<List<Amenity>> call({required int hotelId, required int roomId}) async {
    return await repository.getByRoom(hotelId: hotelId, roomId: roomId);
  }
}
