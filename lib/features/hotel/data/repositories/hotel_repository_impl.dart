import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/paged.dart';
import '../../../../core/network/upload_file.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../datasources/hotel_api.dart';
import '../models/hotel_models.dart';

@LazySingleton(as: HotelRepository)
class HotelRepositoryImpl implements HotelRepository {
  HotelRepositoryImpl(this._api);

  final HotelApi _api;

  @override
  Future<Paged<Hotel>> getHotels({required int page, required int size}) async =>
      (await _api.getHotels(page, size)).parsePage(HotelModel.fromJson);

  @override
  Future<List<Hotel>> getAllHotels() async {
    const size = AppConstants.bulkPageSize;
    final first = await getHotels(page: 0, size: size);
    final hotels = [...first.items];
    for (var page = 1; page < first.totalPages; page++) {
      hotels.addAll((await getHotels(page: page, size: size)).items);
    }
    return hotels;
  }

  @override
  Future<List<Hotel>> searchAvailable({
    required DateTime checkin,
    required DateTime checkout,
  }) async =>
      (await _api.search(Fmt.apiDate(checkin), Fmt.apiDate(checkout)))
          .parseList(HotelModel.fromJson);

  @override
  Future<List<Hotel>> byCategory(String category) async =>
      (await _api.byCategory(category)).parseList(HotelModel.fromJson);

  @override
  Future<HotelDetail> getDetail(
    int id, {
    DateTime? checkin,
    DateTime? checkout,
  }) async {
    final withDates = checkin != null && checkout != null;
    final response = await _api.detail(
      id,
      checkinDate: withDates ? Fmt.apiDate(checkin) : null,
      checkoutDate: withDates ? Fmt.apiDate(checkout) : null,
    );
    return response.parse(HotelModel.detailFromJson);
  }

  @override
  Future<Hotel> create(
    HotelCreateRequest request, {
    List<UploadFile> images = const [],
  }) async {
    final response = await _api.create(
      [jsonPart(request.toJson())],
      images.map((image) => image.toMultipart()).toList(),
    );
    return response.parse(HotelModel.fromJson);
  }

  @override
  Future<Hotel> update(int id, HotelUpdateRequest request) async =>
      (await _api.update(id, request.toJson())).parse(HotelModel.fromJson);

  @override
  Future<void> delete(int id) async => (await _api.delete(id)).ensureSuccess();

  @override
  Future<List<String>> uploadImages(int id, List<UploadFile> images) async =>
      (await _api.uploadImages(
        id,
        images.map((image) => image.toMultipart()).toList(),
      ))
          .stringList;
}
