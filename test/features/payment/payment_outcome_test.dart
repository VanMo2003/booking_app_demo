import 'package:booking_app_mobile/features/payment/domain/entities/payment_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every callback result the backend sends has an outcome', () {
    expect(
        PaymentOutcome.fromCallback('PAYMENT_SUCCESS'), PaymentOutcome.success);
    expect(PaymentOutcome.fromCallback('PAYMENT_ALREADY_DONE'),
        PaymentOutcome.success);
    expect(
        PaymentOutcome.fromCallback('PAYMENT_FAILED'), PaymentOutcome.failed);
    expect(PaymentOutcome.fromCallback('PAYMENT_AMOUNT_MISMATCH'),
        PaymentOutcome.failed);
    expect(
        PaymentOutcome.fromCallback('PAYMENT_EXPIRED'), PaymentOutcome.expired);
    expect(
        PaymentOutcome.fromCallback('something else'), PaymentOutcome.invalid);
  });
}
