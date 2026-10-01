import '../../data/models/tour_booking_models.dart';
import '../entities/tour_booking.dart';

abstract interface class TourBookingRepository {
  /// Khách đặt tour (kèm phòng đã chọn nếu gói có phòng).
  Future<TourBooking> create(TourBookingRequest request);

  /// Đơn tour của khách đang đăng nhập, mới nhất trước.
  Future<List<TourBooking>> mine();

  /// Đơn tour của một cơ sở, mới nhất trước.
  Future<List<TourBooking>> byHotel(int hotelId);

  Future<TourBooking> getById(int id);

  Future<TourBooking> confirm(int id);

  Future<TourBooking> complete(int id);

  Future<TourBooking> cancel(int id, {String? reason});
}
