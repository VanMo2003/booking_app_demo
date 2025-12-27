import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../share/data/models/api_response.dart';

part 'login_api_service.g.dart';

@RestApi()
abstract class LoginApiService {
  factory LoginApiService(Dio dio, {String? baseUrl}) = _LoginApiService;

  @GET('/login')
  Future<ApiResponse> getPosition();
}
