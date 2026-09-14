import 'package:injectable/injectable.dart';

import '../entities/payment_outcome.dart';
import '../repositories/payment_repository.dart';

@injectable
class CreateVnPayLink {
  const CreateVnPayLink(this._repository);

  final PaymentRepository _repository;

  Future<String> call({required int bookingId, required double amount}) =>
      _repository.createVnPayLink(bookingId: bookingId, amount: amount);
}

@injectable
class ConfirmVnPayReturn {
  const ConfirmVnPayReturn(this._repository);

  final PaymentRepository _repository;

  /// URL trả về chứa `vnp_ResponseCode` hoặc đi qua `/payment/vn-pay-callback`.
  static bool isReturnUrl(Uri uri) =>
      uri.queryParameters.containsKey('vnp_ResponseCode') ||
      uri.path.contains('vn-pay-callback');

  Future<PaymentOutcome> call(Uri returnUrl) =>
      _repository.confirmCallback(returnUrl.queryParameters);
}
