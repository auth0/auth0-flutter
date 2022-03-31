class Credentials {
  final String idToken;
  final String accessToken;
  final String? refreshToken;
  final double expiresIn;
  final Set<String> scopes;

  const Credentials(
      {required this.idToken,
      required this.accessToken,
      this.refreshToken,
      required this.expiresIn,
      this.scopes = const {}});
}
