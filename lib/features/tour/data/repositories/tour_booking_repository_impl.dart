import 'package:injectable/injectable.dart';

import '../../domain/entities/tour_booking.dart';
import '../../domain/repositories/tour_booking_repository.dart';
import '../datasources/tour_booking_api.dart';
import '../models/tour_booking_models.dart';

@LazySingleton(as: TourBookingRepository)
class TourBookingRepositoryImpl implements TourBookingRepository {
  TourBookingRepositoryImpl(this._api);

  final TourBookingApi _api;

  @override
  Future<TourBooking> create(TourBookingRequest request) async =>
      (await _api.create(request.toJson())).parse(TourBookingModel.fromJson);

  @override
  Future<List<TourBooking>> mine() async => (await _api.mine()).parseList(TourBookingModel.fromJson);

  @override
  Future<List<TourBooking>> byHotel(int hotelId) async =>
      (await _api.byHotel(hotelId)).parseList(TourBookingModel.fromJson);

  @override
  Future<TourBooking> getById(int id) async => (await _api.getById(id)).parse(TourBookingModel.fromJson);

  @override
  Future<TourBooking> confirm(int id) async => (await _api.confirm(id)).parse(TourBookingModel.fromJson);

  @override
  Future<TourBooking> complete(int id) async => (await _api.complete(id)).parse(TourBookingModel.fromJson);

  @override
  Future<TourBooking> cancel(int id, {String? reason}) async =>
      (await _api.cancel(id, {if (reason != null) 'reason': reason})).parse(TourBookingModel.fromJson);
}
