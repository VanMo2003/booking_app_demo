class AuthToken {
  final bool authenticated;
  final String accessToken;
  final String refreshToken;

  AuthToken({
    required this.authenticated,
    required this.accessToken,
    required this.refreshToken,
  });
}
