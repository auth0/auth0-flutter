class CodeExchangeResult {
  final String idToken;
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final Set<String>? scopes;

  const CodeExchangeResult(
      {required this.idToken,
      required this.accessToken,
      this.refreshToken,
      required this.expiresIn,
      this.scopes});
}

class LoginResult extends CodeExchangeResult {
  final Map<String, String> userProfile;

  const LoginResult(
      {required final String idToken,
      required final String accessToken,
      final String? refreshToken,
      required final int expiresIn,
      final Set<String>? scopes,
      required this.userProfile})
      : super(
            idToken: idToken,
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            scopes: scopes);
}
