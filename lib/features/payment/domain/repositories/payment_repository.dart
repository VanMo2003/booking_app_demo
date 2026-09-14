import '../entities/payment_outcome.dart';

abstract interface class PaymentRepository {
  /// Tạo (hoặc tạo lại) link VNPay; BE gia hạn giữ đơn thêm 15 phút.
  Future<String> createVnPayLink({required int bookingId, required double amount});

  /// Chuyển query VNPay trả về cho BE kiểm chữ ký và cập nhật đơn.
  Future<PaymentOutcome> confirmCallback(Map<String, String> query);
}
