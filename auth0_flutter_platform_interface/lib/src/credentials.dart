class Credentials {
  final String idToken;
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final Set<String> scopes;

  const Credentials(
      {required this.idToken,
      required this.accessToken,
      this.refreshToken,
      required this.expiresAt,
      this.scopes = const {}});
}
