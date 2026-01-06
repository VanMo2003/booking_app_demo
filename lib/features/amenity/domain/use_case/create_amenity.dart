import 'package:booking_app_mobile/features/amenity/data/models/request/amenity_create_request.dart';
import 'package:booking_app_mobile/features/amenity/domain/entity/amenity.dart';
import 'package:booking_app_mobile/features/amenity/domain/respository/amenity_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class CreateAmenity {
  final AmenityRepository repository;

  CreateAmenity(this.repository);

  Future<Amenity> call(AmenityCreateRequest req) async {
    return await repository.create(req);
  }
}
