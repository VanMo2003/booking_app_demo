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

  /// Quản trị viên chỉ xem và xét duyệt — không tạo, sửa, xoá phòng, tiện ích,
  /// dịch vụ hay nhân viên của cơ sở.
  bool get canEditBranchContent => this != Role.admin;

  /// Thực đơn do chủ khách sạn và quản lý cơ sở soạn; nhân viên, quản trị viên chỉ xem.
  bool get canManageMenu => this == Role.hotelOwner || this == Role.hotelManager;

  /// Tour tham quan: cùng quy tắc với thực đơn.
  bool get canManageTours => canManageMenu;
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

/// Đơn tour: chờ khách sạn xác nhận → đã xác nhận → hoàn tất; còn mở thì một trong hai bên huỷ được.
enum TourBookingStatus {
  pending('PENDING'),
  confirmed('CONFIRMED'),
  completed('COMPLETED'),
  canceled('CANCELED');

  const TourBookingStatus(this.value);

  final String value;

  static TourBookingStatus parse(String? raw) =>
      TourBookingStatus.values.firstWhereOrNull((e) => e.value == raw) ??
      TourBookingStatus.pending;

  bool get isOpen => this == TourBookingStatus.pending || this == TourBookingStatus.confirmed;
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

/// Trạng thái xét duyệt hồ sơ chủ khách sạn (`HotelChain.approvalStatus`).
enum ApprovalStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED');

  const ApprovalStatus(this.value);

  final String value;

  /// Chuỗi tạo trước khi có quy trình duyệt không mang trạng thái — coi như đã duyệt.
  static ApprovalStatus parse(String? raw) =>
      ApprovalStatus.values.firstWhereOrNull((e) => e.value == raw) ??
      ApprovalStatus.approved;
}

/// Nhóm món trên thực đơn, theo thứ tự đọc thực đơn (`Dish.category`).
enum DishCategory {
  appetizer('APPETIZER'),
  mainCourse('MAIN_COURSE'),
  sideDish('SIDE_DISH'),
  dessert('DESSERT'),
  drink('DRINK'),
  other('OTHER');

  const DishCategory(this.value);

  final String value;

  static DishCategory parse(String? raw) =>
      DishCategory.values.firstWhereOrNull((e) => e.value == raw) ??
      DishCategory.other;
}

/// Hai phía của một cuộc trò chuyện: khách hàng, hoặc cả đội ngũ cơ sở (chủ
/// khách sạn, quản lý, nhân viên dùng chung một hộp thư).
enum ChatSide {
  customer('CUSTOMER'),
  hotel('HOTEL');

  const ChatSide(this.value);

  final String value;

  static ChatSide parse(String? raw) =>
      ChatSide.values.firstWhereOrNull((e) => e.value == raw) ?? ChatSide.customer;
}

enum NotificationType {
  ownerRegistered('OWNER_REGISTERED'),
  ownerApproved('OWNER_APPROVED'),
  ownerRejected('OWNER_REJECTED'),
  tourBookingCreated('TOUR_BOOKING_CREATED'),
  tourBookingConfirmed('TOUR_BOOKING_CONFIRMED'),
  tourBookingCanceled('TOUR_BOOKING_CANCELED'),
  other('');

  const NotificationType(this.value);

  final String value;

  static NotificationType parse(String? raw) =>
      NotificationType.values.firstWhereOrNull((e) => e.value == raw) ??
      NotificationType.other;
}
