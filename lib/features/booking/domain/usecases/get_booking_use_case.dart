import '../entity/booking_entity.dart';
import '../repositories/booking_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetBookings {
  final BookingRepository repo;
  GetBookings(this.repo);

  Future<List<BookingEntity>> call({
    int? hotelId,
    int? customerId,
    String? bookingStatus,
  }) =>
      repo.getBookings(
        hotelId: hotelId,
        customerId: customerId,
        bookingStatus: bookingStatus,
      );
}
