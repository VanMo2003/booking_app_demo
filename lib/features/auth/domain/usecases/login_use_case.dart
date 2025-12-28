import 'package:booking_app_mobile/features/auth/data/models/request/login_request.dart';
import 'package:injectable/injectable.dart';
import '../entity/auth.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<AuthToken> call(LoginRequest request) async {
    return await repository.login(request);
  }
}
