import 'package:booking_app_mobile/features/auth/data/models/request/login_request.dart';

import '../entity/auth.dart';

abstract class AuthRepository {
  Future<AuthToken> login(LoginRequest request);

  Future<void> logout();
}
