import 'package:booking_app_mobile/features/amenity/domain/respository/amenity_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class DeleteAmenity {
  final AmenityRepository repository;

  DeleteAmenity(this.repository);

  Future<void> call(int id) async {
    return await repository.delete(id);
  }
}
