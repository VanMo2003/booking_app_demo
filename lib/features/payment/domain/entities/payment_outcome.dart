/// Kết quả BE trả sau khi kiểm chữ ký callback VNPay.
enum PaymentOutcome {
  /// `PAYMENT_SUCCESS` — đơn chuyển PAID.
  success,

  /// `PAYMENT_FAILED` — giao dịch huỷ/thất bại, đơn về UNPAID.
  failed,

  /// `PAYMENT_EXPIRED` — quá 15 phút, đơn về FAILED.
  expired,

  /// Chữ ký sai hoặc không gọi được callback.
  invalid;

  static PaymentOutcome fromCallback(String value) => switch (value) {
        'PAYMENT_SUCCESS' => PaymentOutcome.success,
        'PAYMENT_FAILED' => PaymentOutcome.failed,
        'PAYMENT_EXPIRED' => PaymentOutcome.expired,
        _ => PaymentOutcome.invalid,
      };
}
