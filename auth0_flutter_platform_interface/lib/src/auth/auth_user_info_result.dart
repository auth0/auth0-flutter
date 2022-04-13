class AuthUserInfoResult {
  final String? nickname;
  final String? email;
  final String? familyName;
  final String? givenName;
  final DateTime? createdAt;
  final bool? isEmailVerified;
  final String? name;
  final String? pictureURL;
  final Map<String, dynamic>? userMetadata;
  final Map<String, dynamic>? appMetadata;
  final Map<String, dynamic>? extraInfo;

  const AuthUserInfoResult(
      {final this.nickname,
      final this.email,
      final this.familyName,
      final this.givenName,
      final this.createdAt,
      final this.isEmailVerified,
      final this.name,
      final this.pictureURL,
      final this.userMetadata,
      final this.appMetadata,
      final this.extraInfo});

  factory AuthUserInfoResult.fromMap(final Map<String, dynamic> result) =>
      AuthUserInfoResult(
        nickname: result['nickname'] as String?,
        email: result['email'] as String?,
        familyName: result['familyName'] as String?,
        givenName: result['givenName'] as String?,
        createdAt: result['createdAt'] != null
            ? DateTime.parse(result['createdAt'] as String)
            : null,
        isEmailVerified: result['isEmailVerified'] as bool?,
        name: result['name'] as String?,
        pictureURL: result['pictureURL'] as String?,
        userMetadata: result['userMetadata'] != null
            ? Map<String, dynamic>.from(
                result['userMetadata'] as Map<dynamic, dynamic>)
            : null,
        appMetadata: result['appMetadata'] != null
            ? Map<String, dynamic>.from(
                result['appMetadata'] as Map<dynamic, dynamic>)
            : null,
        extraInfo: result['extraInfo'] != null
            ? Map<String, dynamic>.from(
                result['extraInfo'] as Map<dynamic, dynamic>)
            : null,
      );
}
