class AuthRenewAccessTokenResult {
  final String idToken;
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final Set<String> scopes;

  AuthRenewAccessTokenResult(
      {required this.idToken,
      required this.accessToken,
      this.refreshToken,
      required this.expiresAt,
      required this.scopes});

       factory AuthRenewAccessTokenResult.fromMap(
          final Map<dynamic, dynamic> result) =>
      AuthRenewAccessTokenResult(
        idToken: result['idToken'] as String,
        accessToken: result['accessToken'] as String,
        refreshToken: result['refreshToken'] as String?,
        expiresAt: DateTime.parse(result['expiresAt'] as String),
        scopes: Set<String>.from(result['scopes'] as List<Object?>),
      );
}
