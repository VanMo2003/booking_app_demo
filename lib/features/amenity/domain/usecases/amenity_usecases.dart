import 'package:injectable/injectable.dart';

import '../../data/models/amenity_models.dart';
import '../entities/amenity.dart';
import '../repositories/amenity_repository.dart';

@injectable
class GetRoomAmenities {
  const GetRoomAmenities(this._repository);

  final AmenityRepository _repository;

  Future<List<Amenity>> call({required int hotelId, required int roomId}) =>
      _repository.byRoom(hotelId: hotelId, roomId: roomId);
}

@injectable
class CreateAmenity {
  const CreateAmenity(this._repository);

  final AmenityRepository _repository;

  Future<Amenity> call(AmenityCreateRequest request) => _repository.create(request);
}

@injectable
class UpdateAmenity {
  const UpdateAmenity(this._repository);

  final AmenityRepository _repository;

  Future<Amenity> call(int id, AmenityUpdateRequest request) =>
      _repository.update(id, request);
}

@injectable
class DeleteAmenity {
  const DeleteAmenity(this._repository);

  final AmenityRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}

@injectable
class LinkAmenityToRoom {
  const LinkAmenityToRoom(this._repository);

  final AmenityRepository _repository;

  Future<void> call({required int roomId, required int amenityId}) =>
      _repository.linkToRoom(roomId: roomId, amenityId: amenityId);
}
