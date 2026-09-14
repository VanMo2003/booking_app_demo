import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  @POST('/auth/login')
  @Extra({'skipAuth': true})
  Future<ApiResponse> login(@Body() Map<String, dynamic> body);

  @POST('/auth/logout')
  Future<ApiResponse> logout();

  /// Đăng ký công khai chỉ tạo được role CUSTOMER.
  @POST('/accounts')
  @Extra({'skipAuth': true})
  Future<ApiResponse> register(@Body() Map<String, dynamic> body);
}

@module
abstract class AuthApiModule {
  @lazySingleton
  AuthApi authApi(Dio dio) => AuthApi(dio);
}
