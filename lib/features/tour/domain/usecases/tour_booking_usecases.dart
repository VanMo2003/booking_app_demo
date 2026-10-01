import 'package:injectable/injectable.dart';

import '../../data/models/tour_booking_models.dart';
import '../entities/tour_booking.dart';
import '../repositories/tour_booking_repository.dart';

@injectable
class PlaceTourBooking {
  const PlaceTourBooking(this._repository);

  final TourBookingRepository _repository;

  Future<TourBooking> call(TourBookingRequest request) => _repository.create(request);
}

/// Đơn tour: của khách đang đăng nhập (`hotelId` null) hoặc của một cơ sở.
@injectable
class GetTourBookings {
  const GetTourBookings(this._repository);

  final TourBookingRepository _repository;

  Future<List<TourBooking>> call({int? hotelId}) =>
      hotelId == null ? _repository.mine() : _repository.byHotel(hotelId);
}

@injectable
class GetTourBooking {
  const GetTourBooking(this._repository);

  final TourBookingRepository _repository;

  Future<TourBooking> call(int id) => _repository.getById(id);
}

enum TourBookingAction { confirm, complete }

@injectable
class ChangeTourBookingStatus {
  const ChangeTourBookingStatus(this._repository);

  final TourBookingRepository _repository;

  Future<TourBooking> call(int id, TourBookingAction action) => switch (action) {
        TourBookingAction.confirm => _repository.confirm(id),
        TourBookingAction.complete => _repository.complete(id),
      };
}

@injectable
class CancelTourBooking {
  const CancelTourBooking(this._repository);

  final TourBookingRepository _repository;

  Future<TourBooking> call(int id, {String? reason}) => _repository.cancel(id, reason: reason);
}
