import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'payment_api.g.dart';

@RestApi()
abstract class PaymentApi {
  factory PaymentApi(Dio dio, {String? baseUrl}) = _PaymentApi;

  /// `amount` tính bằng VND; BE tự nhân 100 theo chuẩn VNPay.
  @GET('/payment/vn-pay')
  Future<ApiResponse> createVnPayLink(
    @Query('bookingId') int bookingId,
    @Query('amount') int amount, {
    @Query('bankCode') String? bankCode,
  });

  /// Chuyển nguyên query VNPay trả về để BE kiểm chữ ký.
  @GET('/payment/vn-pay-callback')
  Future<ApiResponse> confirmCallback(@Queries() Map<String, dynamic> query);
}

@module
abstract class PaymentApiModule {
  @lazySingleton
  PaymentApi paymentApi(Dio dio) => PaymentApi(dio);
}
