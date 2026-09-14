import '../enums/app_enums.dart';

/// Nhãn tiếng Việt cho enum. Giá trị gốc (`ADMIN`, `PENDING`…) chỉ dùng khi
/// gọi API, không bao giờ hiển thị cho người dùng.

extension RoleLabel on Role {
  String get label => switch (this) {
        Role.admin => 'Quản trị viên',
        Role.hotelOwner => 'Chủ khách sạn',
        Role.hotelManager => 'Quản lý cơ sở',
        Role.staff => 'Nhân viên',
        Role.customer => 'Khách hàng',
      };
}

extension BookingStatusLabel on BookingStatus {
  String get label => switch (this) {
        BookingStatus.paying => 'Đang thanh toán',
        BookingStatus.pending => 'Chờ xác nhận',
        BookingStatus.confirmed => 'Đã xác nhận',
        BookingStatus.completed => 'Hoàn tất',
        BookingStatus.canceled => 'Đã huỷ',
      };
}

extension PaymentStatusLabel on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.unpaid => 'Chưa thanh toán',
        PaymentStatus.pending => 'Chờ thanh toán',
        PaymentStatus.paid => 'Đã thanh toán',
        PaymentStatus.failed => 'Hết hạn thanh toán',
      };
}

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.cash => 'Tiền mặt',
        PaymentMethod.bankTransfer => 'Chuyển khoản',
        PaymentMethod.vnPay => 'VNPay',
      };

  String get description => switch (this) {
        PaymentMethod.cash => 'Trả tại quầy khi nhận phòng',
        PaymentMethod.bankTransfer =>
          'Chuyển khoản, lễ tân xác nhận khi nhận được tiền',
        PaymentMethod.vnPay => 'Thanh toán online ngay, giữ đơn 15 phút',
      };
}

extension RoomStatusLabel on RoomStatus {
  String get label => switch (this) {
        RoomStatus.available => 'Còn trống',
        RoomStatus.booked => 'Đã được đặt',
        RoomStatus.occupied => 'Đang có khách',
        RoomStatus.maintenance => 'Bảo trì',
      };
}

extension HotelStatusLabel on HotelStatus {
  String get label => switch (this) {
        HotelStatus.available => 'Còn phòng',
        HotelStatus.full => 'Hết phòng',
        HotelStatus.inactive => 'Tạm đóng',
      };
}

extension PayrollStatusLabel on PayrollStatus {
  String get label => switch (this) {
        PayrollStatus.approved => 'Đã duyệt',
        PayrollStatus.paid => 'Đã chi',
        PayrollStatus.rejected => 'Từ chối',
      };
}
