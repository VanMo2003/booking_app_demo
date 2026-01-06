import 'package:booking_app_mobile/features/amenity/domain/entity/amenity.dart';
import 'package:booking_app_mobile/features/amenity/domain/respository/amenity_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class GetAmenityByHotel {
  final AmenityRepository repository;

  GetAmenityByHotel(this.repository);

  Future<List<Amenity>> call(int hotelId) async {
    return await repository.getByHotel(hotelId);
  }
}
