class AuthRenewAccessTokenResult {
  final String idToken;
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final Set<String> scopes;

  AuthRenewAccessTokenResult(
      {required this.idToken,
      required this.accessToken,
      this.refreshToken,
      required this.expiresIn,
      required this.scopes});
}
