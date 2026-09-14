import 'package:injectable/injectable.dart';

import '../../../../core/network/app_exception.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/text/error_strings.dart';
import '../../domain/entities/payment_outcome.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_api.dart';

@LazySingleton(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._api);

  final PaymentApi _api;

  @override
  Future<String> createVnPayLink({
    required int bookingId,
    required double amount,
  }) async {
    final response = await _api.createVnPayLink(bookingId, amount.round());
    final url = response.json.str('paymentUrl');
    if (url.isEmpty) throw const AppException(ErrorStrings.badResponse);
    return url;
  }

  @override
  Future<PaymentOutcome> confirmCallback(Map<String, String> query) async {
    try {
      final response = await _api.confirmCallback(query);
      return PaymentOutcome.fromCallback(response.text);
    } on AppException catch (error) {
      // BE trả HTTP 200 + success=false, code 404 khi sai chữ ký.
      if (error.code == 404) return PaymentOutcome.invalid;
      rethrow;
    }
  }
}
