import '../entities/session.dart';

abstract interface class AuthRepository {
  Future<Session> login({required String username, required String password});

  /// Đăng ký công khai — chỉ tạo tài khoản CUSTOMER.
  Future<void> registerCustomer({
    required String username,
    required String password,
  });

  Future<void> logout();

  /// Phiên đã lưu trên máy, `null` nếu chưa đăng nhập hoặc refresh token đã hết hạn.
  Future<Session?> restoreSession();

  Future<void> saveSession(Session session);

  Future<void> clearSession();
}
