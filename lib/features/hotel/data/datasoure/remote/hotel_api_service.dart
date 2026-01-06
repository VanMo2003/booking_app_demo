import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../share/data/models/api_response.dart';


part 'hotel_api_service.g.dart';

@RestApi()
abstract class HotelApiService {
  factory HotelApiService(Dio dio, {String? baseUrl}) = _HotelApiService;

  @GET('/hotels')
  Future<ApiResponse> getHotels(
    @Query('page') int page,
    @Query('size') int size,
  );
}
