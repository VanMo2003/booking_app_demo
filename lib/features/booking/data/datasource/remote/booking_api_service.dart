import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../share/data/models/api_response.dart';
import '../../models/request/booking_create_request.dart';

part 'booking_api_service.g.dart';

@RestApi()
abstract class BookingApiService {
  factory BookingApiService(Dio dio, {String? baseUrl}) = _BookingApiService;

  /// Lấy danh sách booking
  @GET('/bookings')
  Future<ApiResponse> getBookings(
    @Query('hotelId') int? hotelId,
    @Query('customerId') int? customerId,
    @Query('bookingStatus') String? bookingStatus,
  );

  /// Xem chi tiết
  @GET('/bookings/{id}')
  Future<ApiResponse> getBookingById(@Path('id') int id);

  /// Tạo booking
  @POST('/bookings')
  Future<ApiResponse> createBooking(@Body() BookingCreateRequest body);

  /// Xác nhận
  @PUT('/bookings/{id}/confirm')
  Future<ApiResponse> confirmBooking(@Path('id') int id);

  /// Hủy
  @PUT('/bookings/{id}/cancel')
  Future<ApiResponse> cancelBooking(@Path('id') int id);

  /// Hoàn tất
  @PUT('/bookings/{id}/complete')
  Future<ApiResponse> completeBooking(@Path('id') int id);
}
