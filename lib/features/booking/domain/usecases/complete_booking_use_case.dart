import '../entity/booking_entity.dart';
import '../repositories/booking_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CompleteBooking {
  final BookingRepository repo;
  CompleteBooking(this.repo);

  Future<BookingEntity> call(int id) => repo.confirmBooking(id);
}
