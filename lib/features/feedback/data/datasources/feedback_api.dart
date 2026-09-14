import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'feedback_api.g.dart';

@RestApi()
abstract class FeedbackApi {
  factory FeedbackApi(Dio dio, {String? baseUrl}) = _FeedbackApi;

  @POST('/feedbacks')
  Future<ApiResponse> create(@Body() Map<String, dynamic> body);
}

@module
abstract class FeedbackApiModule {
  @lazySingleton
  FeedbackApi feedbackApi(Dio dio) => FeedbackApi(dio);
}
