import 'package:booking_app_mobile/features/auth/data/models/request/login_request.dart';
import 'package:booking_app_mobile/features/auth/data/models/request/register_request.dart';

import '../entity/auth.dart';

abstract class AuthRepository {
  Future<Auth> login(LoginRequest request);

  Future<void> logout();

  Future<void> register(RegisterRequest request);
}
