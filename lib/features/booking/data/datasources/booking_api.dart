import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'booking_api.g.dart';

@RestApi()
abstract class BookingApi {
  factory BookingApi(Dio dio, {String? baseUrl}) = _BookingApi;

  @POST('/bookings')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @PUT('/bookings/{id}')
  Future<ApiResponse> update(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @GET('/bookings/{id}')
  Future<ApiResponse> getById(@Path('id') int id);

  /// Theo cơ sở (`hotelId`, BE bỏ qua `bookingStatus`) hoặc theo khách
  /// (`customerId`, lọc được theo `bookingStatus`).
  @GET('/bookings')
  Future<ApiResponse> list({
    @Query('hotelId') int? hotelId,
    @Query('customerId') int? customerId,
    @Query('bookingStatus') String? bookingStatus,
  });

  @DELETE('/bookings/{id}')
  Future<ApiResponse> delete(@Path('id') int id);

  @PUT('/bookings/{id}/confirm')
  Future<ApiResponse> confirm(@Path('id') int id);

  @PUT('/bookings/{id}/cancel')
  Future<ApiResponse> cancel(@Path('id') int id);

  @PUT('/bookings/{id}/complete')
  Future<ApiResponse> complete(@Path('id') int id);

  /// Body `{"paymentMethod": "CASH" | "BANK_TRANSFER" | "VN_PAY"}`.
  @PUT('/bookings/{id}/payment-method')
  Future<ApiResponse> changePaymentMethod(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  /// API này trả thẳng object đơn, không có khung `ApiResponse`.
  /// Khai báo `dynamic` vì retrofit sinh sai mã với kiểu `Map<String, dynamic>`.
  @PUT('/bookings/{id}/payment-status')
  Future<dynamic> updatePaymentStatus(
    @Path('id') int id,
    @Query('status') String status,
  );
}

@module
abstract class BookingApiModule {
  @lazySingleton
  BookingApi bookingApi(Dio dio) => BookingApi(dio);
}
