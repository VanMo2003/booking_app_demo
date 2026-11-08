import '../../../../core/network/paged.dart';
import '../../domain/entities/travel_theme.dart';
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
  Future<Tour> byId(int id) async => (await _api.byId(id)).parse(TourModel.fromJson);

  @override
  Future<Paged<Tour>> search({String? query, TravelTheme? theme, double? maxPrice, int page = 0}) async =>
      (await _api.search({
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (theme != null) 'theme': theme.value,
        if (maxPrice != null) 'maxPrice': maxPrice.round(),
        'page': page,
        'size': 20,
      }))
          .parse((json) => Paged.fromJson(json, TourModel.fromJson));

  @override
  Future<List<TourDestination>> destinations() async =>
      (await _api.destinations()).parseList(TourModel.destination);

  @override
  Future<TourHome> home(List<TravelTheme> interests) async => (await _api.home(
        interests.isEmpty ? null : interests.map((theme) => theme.value).join(','),
      ))
          .parse(TourModel.home);

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

  @override
  Future<TourStay> availableRooms(int tourId, DateTime date) async =>
      (await _api.availableRooms(tourId, TourStayModel.queryDate(date))).parse(TourStayModel.fromJson);
}
