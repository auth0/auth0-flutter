class AuthRenewAccessTokenResult {
  final String idToken;
  final String accessToken;
  final String? refreshToken;
  final double expiresAt;
  final Set<String> scopes;

  AuthRenewAccessTokenResult(
      {required this.idToken,
      required this.accessToken,
      this.refreshToken,
      required this.expiresAt,
      required this.scopes});
}
