class AuthUserInfoResult {
  final String? nickname;
  final String? email;
  final String? familyName;
  final String? givenName;

  const AuthUserInfoResult(
      {final this.nickname,
      final this.email,
      final this.familyName,
      final this.givenName});

  factory AuthUserInfoResult.fromMap(final Map<String, dynamic> result) => AuthUserInfoResult(
        nickname: result['nickname'] as String?,
        email: result['email'] as String?,
        familyName: result['familyName'] as String?,
        givenName: result['givenName'] as String?,
      );
}
