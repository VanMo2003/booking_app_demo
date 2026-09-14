import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Access/refresh token: giữ trong bộ nhớ để interceptor đọc nhanh, đồng thời
/// lưu vào secure storage để mở lại app vẫn còn phiên.
@lazySingleton
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'auth.access_token';
  static const _refreshKey = 'auth.refresh_token';

  String? _accessToken;
  String? _refreshToken;
  bool _loaded = false;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get hasSession => (_refreshToken ?? '').isNotEmpty;

  Future<void> load() async {
    if (_loaded) return;
    _accessToken = await _storage.read(key: _accessKey);
    _refreshToken = await _storage.read(key: _refreshKey);
    _loaded = true;
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _loaded = true;
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _loaded = true;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
