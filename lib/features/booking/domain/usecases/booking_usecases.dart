import 'package:injectable/injectable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../data/models/booking_models.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

@injectable
class CreateBooking {
  const CreateBooking(this._repository);

  final BookingRepository _repository;

  Future<Booking> call(BookingCreateRequest request) => _repository.create(request);
}

@injectable
class UpdateBooking {
  const UpdateBooking(this._repository);

  final BookingRepository _repository;

  Future<Booking> call(int id, BookingUpdateRequest request) =>
      _repository.update(id, request);
}

@injectable
class GetBooking {
  const GetBooking(this._repository);

  final BookingRepository _repository;

  Future<Booking> call(int id) => _repository.getById(id);
}

@injectable
class GetCustomerBookings {
  const GetCustomerBookings(this._repository);

  final BookingRepository _repository;

  Future<List<Booking>> call(int customerId, {BookingStatus? status}) =>
      _repository.byCustomer(customerId, status: status);
}

@injectable
class GetBranchBookings {
  const GetBranchBookings(this._repository);

  final BookingRepository _repository;

  Future<List<Booking>> call(int hotelId) => _repository.byHotel(hotelId);
}

enum BookingAction { confirm, cancel, complete, markPaid }

/// Chuyển trạng thái đơn — mọi nút trên màn chi tiết đi qua đây.
@injectable
class ChangeBookingStatus {
  const ChangeBookingStatus(this._repository);

  final BookingRepository _repository;

  Future<Booking> call(int id, BookingAction action) => switch (action) {
        BookingAction.confirm => _repository.confirm(id),
        BookingAction.cancel => _repository.cancel(id),
        BookingAction.complete => _repository.complete(id),
        BookingAction.markPaid => _repository.markPaid(id),
      };
}

@injectable
class DeleteBooking {
  const DeleteBooking(this._repository);

  final BookingRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
