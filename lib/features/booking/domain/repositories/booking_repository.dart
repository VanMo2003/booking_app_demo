import '../../data/models/request/booking_create_request.dart';
import '../entity/booking_entity.dart';

abstract class BookingRepository {
  Future<List<BookingEntity>> getBookings({
    int? hotelId,
    int? customerId,
    String? bookingStatus,
  });

  Future<BookingEntity> getBookingById(int id);

  Future<BookingEntity> createBooking(BookingCreateRequest dto);

  Future<BookingEntity> confirmBooking(int id);

  Future<BookingEntity> cancelBooking(int id);

  Future<BookingEntity> completeBooking(int id);
}
