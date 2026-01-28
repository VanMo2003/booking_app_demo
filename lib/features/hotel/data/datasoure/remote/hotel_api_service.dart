import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../share/data/models/api_response.dart';

part 'hotel_api_service.g.dart';

@RestApi()
abstract class HotelApiService {
  factory HotelApiService(Dio dio, {String? baseUrl}) = _HotelApiService;

  @GET('/hotels/search')
  Future<ApiResponse> getHotels(
    @Query('checkinDate') String checkinDate,
    @Query('checkoutDate') String checkoutDate,
  );

  @GET('/hotels/{id}')
  Future<ApiResponse> getHotelById(
    @Path('id') int id,
  );

  @MultiPart()
  @POST('/hotels/{id}/images')
  Future<ApiResponse> uploadHotelImages(
    @Path('id') int id,
    @Part(name: 'files') List<MultipartFile> files,
  );
}
