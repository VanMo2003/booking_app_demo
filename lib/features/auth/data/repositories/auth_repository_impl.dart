import 'package:injectable/injectable.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/text/error_strings.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api.dart';
import '../datasources/session_local_data_source.dart';
import '../models/session_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._tokens, this._local);

  final AuthApi _api;
  final TokenStorage _tokens;
  final SessionLocalDataSource _local;

  @override
  Future<Session> login({
    required String username,
    required String password,
  }) async {
    final response = await _api.login({
      'username': username,
      'password': password,
    });
    final json = response.json;
    final access = json.strOrNull('accessToken');
    final refresh = json.strOrNull('refreshToken');
    if (access == null || refresh == null) {
      throw const AppException(ErrorStrings.badResponse);
    }
    await _tokens.save(accessToken: access, refreshToken: refresh);
    final session = SessionModel.fromLogin(json, fallbackUsername: username);
    await _local.write(session);
    return session;
  }

  @override
  Future<void> registerCustomer({
    required String username,
    required String password,
  }) async {
    final response = await _api.register({
      'username': username,
      'password': password,
      'role': Role.customer.value,
      'status': true,
    });
    response.ensureSuccess();
  }

  @override
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Token có thể đã hết hạn — vẫn xoá phiên trên máy.
    } finally {
      await clearSession();
    }
  }

  @override
  Future<Session?> restoreSession() async {
    await _tokens.load();
    final refresh = _tokens.refreshToken;
    if (refresh == null || JwtDecoder.isExpired(refresh, leeway: Duration.zero)) {
      await clearSession();
      return null;
    }
    final session = await _local.read();
    if (session == null) await _tokens.clear();
    return session;
  }

  @override
  Future<void> saveSession(Session session) => _local.write(session);

  @override
  Future<void> clearSession() async {
    await _tokens.clear();
    await _local.clear();
  }
}
