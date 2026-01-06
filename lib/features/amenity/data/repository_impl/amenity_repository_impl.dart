import 'package:booking_app_mobile/features/amenity/data/mapper/amenity_mapper.dart';
import 'package:booking_app_mobile/features/amenity/data/models/amenity_response.dart';
import 'package:injectable/injectable.dart';

import '../../../share/data/models/api_response.dart';
import '../../domain/entity/amenity.dart';
import '../../domain/respository/amenity_repository.dart';
import '../datasource/remote/amenity_api_service.dart';
import '../models/request/amenity_create_request.dart';
import '../models/request/amenity_update_request.dart';

@LazySingleton(as: AmenityRepository)
class AmenityRepositoryImpl implements AmenityRepository {
  final AmenityApiService api;
  AmenityRepositoryImpl(this.api);

  @override
  Future<Amenity> create(AmenityCreateRequest req) async {
    final ApiResponse res = await api.createAmenity(req);
    final data = res.data;
    if (data is! Map<String, dynamic>) throw Exception('Unexpected amenity create format');

    Amenity amenity = AmenityMapper.toEntity(AmenityResponse.fromJson(data));

    return amenity;
  }

  @override
  Future<Amenity> update(int id, AmenityUpdateRequest req) async {
    final ApiResponse res = await api.updateAmenity(id, req);
    final data = res.data;
    if (data is! Map<String, dynamic>) throw Exception('Unexpected amenity update format');
    Amenity amenity = AmenityMapper.toEntity(AmenityResponse.fromJson(data));
    return amenity;
  }

  @override
  Future<List<Amenity>> getByHotel(int hotelId) async {
    final ApiResponse res = await api.getAmenitiesByHotel(hotelId);
    final data = res.data;
    if (data is! List) throw Exception('Unexpected amenity list format');

    List<Amenity>? items;
    items ??= [];

    for (var item in data) {
      items.add(AmenityMapper.toEntity(AmenityResponse.fromJson(item)));
    }

    return items;
  }

  @override
  Future<List<Amenity>> getByRoom({required int hotelId, required int roomId}) async {
    final ApiResponse res = await api.getAmenitiesByRoom(hotelId, roomId);
    final data = res.data;
    if (data is! List) throw Exception('Unexpected amenity list format');

    List<Amenity>? items;
    items ??= [];

    for (var item in data) {
      items.add(AmenityMapper.toEntity(AmenityResponse.fromJson(item)));
    }

    return items;
  }

  @override
  Future<void> delete(int id) async {
    await api.deleteAmenity(id);
  }
}
