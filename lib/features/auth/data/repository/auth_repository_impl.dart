import 'package:booking_app_mobile/core/api/dio_client.dart';
import 'package:booking_app_mobile/features/auth/data/datasource/remote/auth_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/key_constant.dart';
import '../models/response/login_response.dart';
import '../models/request/login_request.dart';
import '../models/request/register_request.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entity/auth.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;
  final DioClient dioClient;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl(this.apiService, this.dioClient, this.secureStorage);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final apiResp = await apiService.login(request);

      final data = apiResp.data as Map<String, dynamic>;
      final loginResp = LoginResponse.fromJson(data);

      await secureStorage.write(
          key: KeyConstant.accessToken, value: loginResp.accessToken);
      await secureStorage.write(
          key: KeyConstant.refreshToken, value: loginResp.refreshToken);

      return AuthResponse(
        authenticated: loginResp.authenticated,
        accessToken: loginResp.accessToken,
        refreshToken: loginResp.refreshToken,
        role: loginResp.role,
        hotel: loginResp.hotel,
        customer: loginResp.customer,
        employee: loginResp.employee,
      );
    } on DioException catch (e) {
      throw dioClient.handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiService.logout();
      await secureStorage.delete(key: KeyConstant.accessToken);
      await secureStorage.delete(key: KeyConstant.refreshToken);
    } on DioException catch (e) {
      throw dioClient.handleDioError(e);
    }
  }

  @override
  Future<void> register(RegisterRequest request) async {
    try {
      await apiService.register(request);
    } on DioException catch (e) {
      throw dioClient.handleDioError(e);
    }
  }
}
