import 'package:booking_app_mobile/features/login/data/models/request/login_request.dart';

import '../entity/login.dart';

abstract class AuthRepository {
  Future<AuthToken> login(LoginRequest request);
}
