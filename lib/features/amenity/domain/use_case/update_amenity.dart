import 'package:booking_app_mobile/features/amenity/data/models/request/amenity_update_request.dart';
import 'package:booking_app_mobile/features/amenity/domain/entity/amenity.dart';
import 'package:booking_app_mobile/features/amenity/domain/respository/amenity_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class UpdateAmenity {
  final AmenityRepository repository;

  UpdateAmenity(this.repository);

  Future<Amenity> call(int id, AmenityUpdateRequest req) async {
    return await repository.update(id, req);
  }
}
