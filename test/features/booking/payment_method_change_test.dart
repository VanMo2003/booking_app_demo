import 'package:booking_app_mobile/core/enums/app_enums.dart';
import 'package:booking_app_mobile/core/text/error_strings.dart';
import 'package:booking_app_mobile/features/booking/domain/entities/booking.dart';
import 'package:flutter_test/flutter_test.dart';

Booking _booking({
  BookingStatus status = BookingStatus.pending,
  PaymentStatus paymentStatus = PaymentStatus.unpaid,
  PaymentMethod method = PaymentMethod.cash,
}) =>
    Booking(
      id: 1,
      checkinDate: DateTime(2026, 10, 10),
      checkoutDate: DateTime(2026, 10, 12),
      status: status,
      paymentMethod: method,
      paymentStatus: paymentStatus,
      totalAmount: 1200000,
    );

void main() {
  group('Booking.canChangePaymentMethod', () {
    test('đơn còn mở, chưa trả tiền: đổi được', () {
      expect(_booking().canChangePaymentMethod, isTrue);
      expect(_booking(status: BookingStatus.confirmed).canChangePaymentMethod, isTrue);
      // VNPay hết hạn vẫn đổi được sang tiền mặt.
      expect(
        _booking(method: PaymentMethod.vnPay, paymentStatus: PaymentStatus.failed).canChangePaymentMethod,
        isTrue,
      );
    });

    test('đã thanh toán hoặc đơn đã đóng: không đổi được', () {
      expect(_booking(paymentStatus: PaymentStatus.paid).canChangePaymentMethod, isFalse);
      expect(_booking(status: BookingStatus.completed).canChangePaymentMethod, isFalse);
      expect(_booking(status: BookingStatus.canceled).canChangePaymentMethod, isFalse);
    });
  });

  test('lỗi BE khi đổi phương thức được dịch sang tiếng Việt', () {
    expect(
      ErrorStrings.translate('Paid bookings keep their payment method', code: 1019, status: 400),
      'Đơn đã thanh toán nên không đổi được phương thức thanh toán.',
    );
    expect(
      ErrorStrings.translate('Closed bookings keep their payment method', code: 1019, status: 400),
      contains('đã huỷ'),
    );
  });
}
