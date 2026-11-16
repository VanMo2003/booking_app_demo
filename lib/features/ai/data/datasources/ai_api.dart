import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'ai_api.g.dart';

/// Các tính năng AI đều gọi qua BE — app không bao giờ giữ API key của Claude.
@RestApi()
abstract class AiApi {
  factory AiApi(Dio dio, {String? baseUrl}) = _AiApi;

  @GET('/ai/status')
  Future<ApiResponse> status();

  @POST('/ai/search')
  Future<ApiResponse> search(@Body() Map<String, dynamic> body);

  @POST('/ai/tours/search')
  Future<ApiResponse> searchTours(@Body() Map<String, dynamic> body);

  @POST('/ai/trip-plan')
  Future<ApiResponse> planTrip(@Body() Map<String, dynamic> body);

  @GET('/ai/hotels/{hotelId}/review-digest')
  Future<ApiResponse> reviewDigest(@Path('hotelId') int hotelId);

  @POST('/ai/tours/draft')
  Future<ApiResponse> draftTour(@Body() Map<String, dynamic> body);

  @POST('/ai/reports/ask')
  Future<ApiResponse> askReports(@Body() Map<String, dynamic> body);

  @GET('/ai/branches/{hotelId}/pricing-advice')
  Future<ApiResponse> pricingAdvice(@Path('hotelId') int hotelId);

  @POST('/ai/assistant/ask')
  Future<ApiResponse> askAssistant(@Body() Map<String, dynamic> body);

  @GET('/ai/conversations/{id}/summary')
  Future<ApiResponse> chatSummary(@Path('id') int conversationId);

  @GET('/ai/chains/{hotelChainId}/review-themes')
  Future<ApiResponse> reviewThemes(
    @Path('hotelChainId') int hotelChainId,
    @Query('from') String from,
    @Query('to') String to,
  );

  @GET('/ai/branches/{hotelId}/content-audit')
  Future<ApiResponse> contentAudit(@Path('hotelId') int hotelId);

  @POST('/ai/conversations/{id}/suggest-reply')
  Future<ApiResponse> suggestReply(@Path('id') int conversationId);

  @GET('/ai/branches/{hotelId}/settings')
  Future<ApiResponse> settings(@Path('hotelId') int hotelId);

  @PUT('/ai/branches/{hotelId}/settings')
  Future<ApiResponse> updateSettings(
    @Path('hotelId') int hotelId,
    @Body() Map<String, dynamic> body,
  );
}

@module
abstract class AiApiModule {
  @lazySingleton
  AiApi aiApi(Dio dio) => AiApi(dio);
}
