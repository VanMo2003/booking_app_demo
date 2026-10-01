import 'package:injectable/injectable.dart';

import '../../../../core/network/upload_file.dart';
import '../../domain/entities/tour.dart';
import '../../domain/repositories/tour_repository.dart';
import '../datasources/tour_api.dart';
import '../models/tour_models.dart';

@LazySingleton(as: TourRepository)
class TourRepositoryImpl implements TourRepository {
  TourRepositoryImpl(this._api);

  final TourApi _api;

  @override
  Future<List<Tour>> byHotel(int hotelId) async =>
      (await _api.byHotel(hotelId)).parseList(TourModel.fromJson);

  @override
  Future<Tour> create(TourRequest request) async =>
      (await _api.create(request.toJson())).parse(TourModel.fromJson);

  @override
  Future<Tour> update(int id, TourRequest request) async =>
      (await _api.update(id, request.toJson())).parse(TourModel.fromJson);

  @override
  Future<Tour> setAvailable(int id, bool available) async =>
      (await _api.update(id, {'available': available})).parse(TourModel.fromJson);

  @override
  Future<Tour> uploadImage(int id, UploadFile image) async =>
      (await _api.uploadImage(id, [image.toMultipart()])).parse(TourModel.fromJson);

  @override
  Future<void> delete(int id) async => (await _api.delete(id)).ensureSuccess();
}
