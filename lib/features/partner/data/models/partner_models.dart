import '../../../hotel_chain/data/models/hotel_chain_models.dart';

/// Đăng ký chủ khách sạn: tài khoản đăng nhập + hồ sơ khách sạn chờ duyệt.
class OwnerRegistrationRequest {
  const OwnerRegistrationRequest({
    required this.username,
    required this.password,
    required this.profile,
  });

  final String username;
  final String password;
  final HotelChainProfile profile;

  Map<String, dynamic> toJson() => {
        'username': username.trim(),
        'password': password,
        ...profile.toJson(),
      };
}
