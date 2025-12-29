import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../share/data/models/api_response.dart';
import '../../models/request/login_request.dart';
import '../../models/request/register_request.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String? baseUrl}) = _AuthApiService;

  @POST('/auth/login')
  Future<ApiResponse> login(@Body() LoginRequest body);

  @POST('/auth/logout')
  Future<ApiResponse> logout();

  @POST('/accounts')
  Future<ApiResponse> register(@Body() RegisterRequest body);
}
