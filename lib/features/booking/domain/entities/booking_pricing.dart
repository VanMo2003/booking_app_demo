import '../../../room/domain/entities/room.dart';
import '../../../service/domain/entities/hotel_service.dart';

/// Tổng tiền đơn. BE lưu nguyên `totalAmount` FE gửi lên, nên công thức nằm ở
/// domain: Σ giá phòng × số đêm + Σ đơn giá dịch vụ (mỗi dịch vụ một lượt).
class BookingPricing {
  const BookingPricing({
    required this.rooms,
    required this.services,
    required this.nights,
  });

  final List<Room> rooms;
  final List<HotelService> services;
  final int nights;

  double get roomsSubtotal =>
      rooms.fold(0, (sum, room) => sum + room.price * nights);

  double get servicesSubtotal =>
      services.fold(0, (sum, service) => sum + service.unitPrice);

  double get total => roomsSubtotal + servicesSubtotal;
}
