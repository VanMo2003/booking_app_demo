import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'tour_booking_api.g.dart';

@RestApi()
abstract class TourBookingApi {
  factory TourBookingApi(Dio dio, {String? baseUrl}) = _TourBookingApi;

  @POST('/tour-bookings')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);

  @GET('/tour-bookings/me')
  Future<ApiResponse> mine();

  @GET('/tour-bookings')
  Future<ApiResponse> byHotel(@Query('hotelId') int hotelId);

  @GET('/tour-bookings/{id}')
  Future<ApiResponse> getById(@Path('id') int id);

  @PUT('/tour-bookings/{id}/confirm')
  Future<ApiResponse> confirm(@Path('id') int id);

  @PUT('/tour-bookings/{id}/complete')
  Future<ApiResponse> complete(@Path('id') int id);

  /// Body `{"reason": "..."}` — khách được bỏ trống, phía cơ sở bắt buộc.
  @PUT('/tour-bookings/{id}/cancel')
  Future<ApiResponse> cancel(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );
}

@module
abstract class TourBookingApiModule {
  @lazySingleton
  TourBookingApi tourBookingApi(Dio dio) => TourBookingApi(dio);
}
