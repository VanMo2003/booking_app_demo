import 'package:injectable/injectable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_api.dart';
import '../models/booking_models.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._api);

  final BookingApi _api;

  @override
  Future<Booking> create(BookingCreateRequest request) async =>
      (await _api.create(request.toJson())).parse(BookingModel.fromJson);

  @override
  Future<Booking> update(int id, BookingUpdateRequest request) async {
    (await _api.update(id, request.toJson())).ensureSuccess();
    // Response của PUT thiếu thông tin phòng/dịch vụ — đọc lại đơn.
    return getById(id);
  }

  @override
  Future<Booking> getById(int id) async =>
      (await _api.getById(id)).parse(BookingModel.fromJson);

  @override
  Future<List<Booking>> byHotel(int hotelId) async =>
      _sorted((await _api.list(hotelId: hotelId)).parseList(BookingModel.fromJson));

  @override
  Future<List<Booking>> byCustomer(int customerId, {BookingStatus? status}) async =>
      _sorted(
        (await _api.list(customerId: customerId, bookingStatus: status?.value))
            .parseList(BookingModel.fromJson),
      );

  @override
  Future<void> delete(int id) async => (await _api.delete(id)).ensureSuccess();

  @override
  Future<Booking> confirm(int id) async =>
      (await _api.confirm(id)).parse(BookingModel.fromJson);

  @override
  Future<Booking> cancel(int id) async =>
      (await _api.cancel(id)).parse(BookingModel.fromJson);

  @override
  Future<Booking> complete(int id) async =>
      (await _api.complete(id)).parse(BookingModel.fromJson);

  @override
  Future<Booking> markPaid(int id) async {
    final raw = await _api.updatePaymentStatus(id, PaymentStatus.paid.value);
    final json = Map<String, dynamic>.from(raw as Map);
    // Phòng khi BE chuyển sang bọc response theo khung chung.
    final data = json['data'];
    return BookingModel.fromJson(data is Map ? Map<String, dynamic>.from(data) : json);
  }

  /// Đơn mới nhất lên đầu.
  List<Booking> _sorted(List<Booking> bookings) => bookings
    ..sort((a, b) {
      final byCreated =
          (b.createdAt ?? b.checkinDate).compareTo(a.createdAt ?? a.checkinDate);
      return byCreated != 0 ? byCreated : b.id - a.id;
    });
}
