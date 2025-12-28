import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../datasource/remote/login_api_service.dart';
import '../models/response/login_response.dart';
import '../models/request/login_request.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entity/login.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final LoginApiService apiService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRepositoryImpl(this.apiService);

  @override
  Future<AuthToken> login(LoginRequest request) async {
    final apiResp = await apiService.login(request);

    final data = apiResp.data as Map<String, dynamic>;
    final loginResp = LoginResponse.fromJson(data);

    // // store tokens
    // await _secureStorage.write(
    //     key: 'access_token', value: loginResp.accessToken);
    // await _secureStorage.write(
    //     key: 'refresh_token', value: loginResp.refreshToken);

    return AuthToken(
      authenticated: loginResp.authenticated,
      accessToken: loginResp.accessToken,
      refreshToken: loginResp.refreshToken,
    );
  }
}
