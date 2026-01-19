import '../../data/models/request/booking_create_request.dart';
import '../entity/booking_entity.dart';
import '../repositories/booking_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateBooking {
  final BookingRepository repo;
  CreateBooking(this.repo);

  Future<BookingEntity> call(BookingCreateRequest dto) =>
      repo.createBooking(dto);
}
