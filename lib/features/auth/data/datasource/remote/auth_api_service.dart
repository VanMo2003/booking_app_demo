import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../models/request/login_request.dart';
import '../../../../share/data/models/api_response.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String? baseUrl}) = _AuthApiService;

  @POST('/auth/login')
  Future<ApiResponse> login(@Body() LoginRequest body);

  @POST('/auth/logout')
  Future<ApiResponse> logout();
}
