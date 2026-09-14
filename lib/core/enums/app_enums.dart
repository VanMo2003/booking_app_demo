import 'package:collection/collection.dart';

/// Enum dùng chung, khớp 1-1 với `entity/enums` phía BE.
/// Nhãn tiếng Việt nằm ở `core/text/enum_labels.dart`, màu ở `core/color/status_colors.dart`.

enum Role {
  admin('ADMIN'),
  hotelOwner('HOTEL_OWNER'),
  hotelManager('HOTEL_MANAGER'),
  staff('STAFF'),
  customer('CUSTOMER');

  const Role(this.value);

  final String value;

  static Role? tryParse(String? raw) =>
      Role.values.firstWhereOrNull((e) => e.value == raw);

  /// Quản lý cơ sở trở lên: được xoá dữ liệu, xem báo cáo, quản lý nhân viên.
  bool get isManagerOrAbove =>
      this == Role.admin || this == Role.hotelOwner || this == Role.hotelManager;

  bool get isBackOffice => this != Role.customer;
}

enum BookingStatus {
  paying('PAYING'),
  pending('PENDING'),
  confirmed('CONFIRMED'),
  completed('COMPLETED'),
  canceled('CANCELED');

  const BookingStatus(this.value);

  final String value;

  static BookingStatus parse(String? raw) =>
      BookingStatus.values.firstWhereOrNull((e) => e.value == raw) ??
      BookingStatus.pending;

  bool get isOpen =>
      this == BookingStatus.pending ||
      this == BookingStatus.paying ||
      this == BookingStatus.confirmed;

  bool get canConfirm =>
      this == BookingStatus.pending || this == BookingStatus.paying;
}

enum PaymentStatus {
  unpaid('UNPAID'),
  pending('PENDING'),
  paid('PAID'),
  failed('FAILED');

  const PaymentStatus(this.value);

  final String value;

  static PaymentStatus parse(String? raw) =>
      PaymentStatus.values.firstWhereOrNull((e) => e.value == raw) ??
      PaymentStatus.unpaid;
}

enum PaymentMethod {
  cash('CASH'),
  bankTransfer('BANK_TRANSFER'),
  vnPay('VN_PAY');

  const PaymentMethod(this.value);

  final String value;

  static PaymentMethod parse(String? raw) =>
      PaymentMethod.values.firstWhereOrNull((e) => e.value == raw) ??
      PaymentMethod.cash;
}

enum RoomStatus {
  available('AVAILABLE'),
  booked('BOOKED'),
  occupied('OCCUPIED'),
  maintenance('MAINTENANCE');

  const RoomStatus(this.value);

  final String value;

  static RoomStatus parse(String? raw) =>
      RoomStatus.values.firstWhereOrNull((e) => e.value == raw) ??
      RoomStatus.available;

  bool get isBookable => this == RoomStatus.available;
}

enum HotelStatus {
  available('AVAILABLE'),
  full('FULL'),
  inactive('INACTIVE');

  const HotelStatus(this.value);

  final String value;

  static HotelStatus? tryParse(String? raw) =>
      HotelStatus.values.firstWhereOrNull((e) => e.value == raw);
}

enum PayrollStatus {
  approved('APPROVED'),
  paid('PAID'),
  rejected('REJECTED');

  const PayrollStatus(this.value);

  final String value;
}
