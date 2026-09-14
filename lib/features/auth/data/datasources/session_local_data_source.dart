import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/session.dart';
import '../models/session_model.dart';

/// Lưu hồ sơ phiên đăng nhập trong secure storage để mở lại app không phải đăng nhập.
@lazySingleton
class SessionLocalDataSource {
  SessionLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  Future<Session?> read() async {
    final raw = await _storage.read(key: StorageKeys.session);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? SessionModel.fromJson(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> write(Session session) => _storage.write(
        key: StorageKeys.session,
        value: jsonEncode(SessionModel.toJson(session)),
      );

  Future<void> clear() => _storage.delete(key: StorageKeys.session);
}
