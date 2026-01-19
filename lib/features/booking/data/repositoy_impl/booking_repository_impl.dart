import 'package:booking_app_mobile/features/booking/data/datasource/remote/booking_api_service.dart';
import 'package:booking_app_mobile/features/booking/data/models/request/booking_create_request.dart';
import 'package:booking_app_mobile/features/booking/data/models/response/booking_response.dart';
import 'package:booking_app_mobile/features/booking/domain/entity/booking_entity.dart';
import 'package:booking_app_mobile/features/booking/domain/repositories/booking_repository.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/dio_client.dart';
import '../../../share/data/models/api_response.dart';
import '../mapper/booking_mapper.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingApiService apiService;
  final DioClient dioClient;

  BookingRepositoryImpl(this.apiService, this.dioClient);

  @override
  Future<BookingEntity> cancelBooking(int id) async {
    try {
      final ApiResponse response = await apiService.cancelBooking(id);
      return BookingMapper.toEntity(
        BookingResponse.fromJson(response.data),
      );
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<BookingEntity> completeBooking(int id) async {
    try {
      final ApiResponse response = await apiService.completeBooking(id);
      return BookingMapper.toEntity(
        BookingResponse.fromJson(response.data),
      );
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<BookingEntity> confirmBooking(int id) async {
    try {
      final ApiResponse response = await apiService.confirmBooking(id);
      return BookingMapper.toEntity(
        BookingResponse.fromJson(response.data),
      );
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<BookingEntity> createBooking(BookingCreateRequest dto) async {
    try {
      final ApiResponse response = await apiService.createBooking(dto);
      return BookingMapper.toEntity(
        BookingResponse.fromJson(response.data),
      );
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<BookingEntity> getBookingById(int id) async {
    try {
      final ApiResponse response = await apiService.getBookingById(id);
      return BookingMapper.toEntity(
        BookingResponse.fromJson(response.data),
      );
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }

  @override
  Future<List<BookingEntity>> getBookings({
    int? customerId,
    int? hotelId,
    String? bookingStatus,
  }) async {
    try {
      final ApiResponse response = await apiService.getBookings(
        hotelId,
        customerId,
        bookingStatus,
      );

      final List list = response.data as List;

      return list
          .map(
            (e) => BookingMapper.toEntity(
              BookingResponse.fromJson(e),
            ),
          )
          .toList();
    } catch (e) {
      throw dioClient.handleDioError(e as DioException);
    }
  }
}
