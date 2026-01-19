import 'package:injectable/injectable.dart';

import '../entity/booking_entity.dart';
import '../repositories/booking_repository.dart';

@injectable
class CancelBooking {
  final BookingRepository repo;
  CancelBooking(this.repo);

  Future<BookingEntity> call(int id) => repo.confirmBooking(id);
}
