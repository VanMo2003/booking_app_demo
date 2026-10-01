import '../entities/tour_booking.dart';

abstract interface class TourBookingRepository {
  /// Đơn tour của khách đang đăng nhập, mới nhất trước.
  Future<List<TourBooking>> mine();

  /// Đơn tour của một cơ sở, mới nhất trước.
  Future<List<TourBooking>> byHotel(int hotelId);

  Future<TourBooking> getById(int id);

  Future<TourBooking> confirm(int id);

  Future<TourBooking> complete(int id);

  Future<TourBooking> cancel(int id, {String? reason});
}
