import 'package:injectable/injectable.dart';

import '../../domain/entities/amenity.dart';
import '../../domain/repositories/amenity_repository.dart';
import '../datasources/amenity_api.dart';
import '../models/amenity_models.dart';

@LazySingleton(as: AmenityRepository)
class AmenityRepositoryImpl implements AmenityRepository {
  AmenityRepositoryImpl(this._api);

  final AmenityApi _api;

  @override
  Future<List<Amenity>> commonByHotel(int hotelId) async =>
      (await _api.byHotel(hotelId)).parseList(AmenityModel.fromJson);

  @override
  Future<List<Amenity>> byRoom({required int hotelId, required int roomId}) async =>
      (await _api.byRoom(hotelId, roomId)).parseList(AmenityModel.fromJson);

  @override
  Future<Amenity> create(AmenityCreateRequest request) async =>
      (await _api.create(request.toJson())).parse(AmenityModel.fromJson);

  @override
  Future<Amenity> update(int id, AmenityUpdateRequest request) async =>
      (await _api.update(id, request.toJson())).parse(AmenityModel.fromJson);

  @override
  Future<void> delete(int id) async => (await _api.delete(id)).ensureSuccess();

  @override
  Future<void> linkToRoom({required int roomId, required int amenityId}) async =>
      (await _api.linkToRoom({
        'roomId': roomId,
        'amenityId': amenityId,
        'quantity': 1,
      }))
          .ensureSuccess();
}
