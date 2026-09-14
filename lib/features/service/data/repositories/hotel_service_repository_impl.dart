import 'package:injectable/injectable.dart';

import '../../domain/entities/hotel_service.dart';
import '../../domain/repositories/hotel_service_repository.dart';
import '../datasources/service_api.dart';
import '../models/hotel_service_models.dart';

@LazySingleton(as: HotelServiceRepository)
class HotelServiceRepositoryImpl implements HotelServiceRepository {
  HotelServiceRepositoryImpl(this._api);

  final ServiceApi _api;

  @override
  Future<List<HotelService>> byHotel(int hotelId) async =>
      (await _api.byHotel(hotelId)).parseList(HotelServiceModel.fromJson);

  @override
  Future<HotelService> create(ServiceRequest request) async =>
      (await _api.create(request.toJson())).parse(HotelServiceModel.fromJson);

  @override
  Future<HotelService> update(int id, ServiceRequest request) async =>
      (await _api.update(id, request.toJson())).parse(HotelServiceModel.fromJson);

  @override
  Future<void> delete(int id) async => (await _api.delete(id)).ensureSuccess();
}
