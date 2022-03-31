class AuthCodeExchangeResult {
  final String idToken;
  final String accessToken;
  final String? refreshToken;
  final double expiresIn;
  final Set<String> scopes;

  AuthCodeExchangeResult(
      {required this.idToken,
      required this.accessToken,
      this.refreshToken,
      required this.expiresIn,
      required this.scopes});
}
