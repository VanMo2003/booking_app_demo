import '../entity/booking_entity.dart';
import '../repositories/booking_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class ConfirmBooking {
  final BookingRepository repo;
  ConfirmBooking(this.repo);

  Future<BookingEntity> call(int id) => repo.confirmBooking(id);
}
