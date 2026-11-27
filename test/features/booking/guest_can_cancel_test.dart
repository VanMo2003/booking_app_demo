import 'package:booking_app_mobile/core/enums/app_enums.dart';
import 'package:booking_app_mobile/core/utils/date_utils.dart';
import 'package:booking_app_mobile/features/booking/domain/entities/booking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Booking booking({required DateTime checkin, PaymentStatus payment = PaymentStatus.unpaid}) => Booking(
        id: 1,
        checkinDate: checkin,
        checkoutDate: DateOnly.addDays(checkin, 2),
        status: BookingStatus.pending,
        paymentStatus: payment,
        paymentMethod: PaymentMethod.cash,
        totalAmount: 1000000,
      );

  test('khách huỷ được đơn chưa trả tiền trước ngày nhận phòng', () {
    expect(booking(checkin: DateOnly.addDays(DateOnly.today(), 3)).guestCanCancel, isTrue);
  });

  test('đơn đã thanh toán hoặc đã tới ngày nhận phòng phải huỷ qua cơ sở', () {
    final later = DateOnly.addDays(DateOnly.today(), 3);
    expect(booking(checkin: later, payment: PaymentStatus.paid).guestCanCancel, isFalse);
    expect(booking(checkin: DateOnly.today()).guestCanCancel, isFalse);
  });
}
