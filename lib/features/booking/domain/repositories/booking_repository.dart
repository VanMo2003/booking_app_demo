import '../../../../core/enums/app_enums.dart';
import '../../data/models/booking_models.dart';
import '../entities/booking.dart';

abstract interface class BookingRepository {
  Future<Booking> create(BookingCreateRequest request);

  Future<Booking> update(int id, BookingUpdateRequest request);

  Future<Booking> getById(int id);

  Future<List<Booking>> byHotel(int hotelId);

  Future<List<Booking>> byCustomer(int customerId, {BookingStatus? status});

  Future<void> delete(int id);

  Future<Booking> confirm(int id);

  Future<Booking> cancel(int id);

  Future<Booking> complete(int id);

  /// Ghi nhận đã thu tiền (tiền mặt / chuyển khoản).
  Future<Booking> markPaid(int id);
}
