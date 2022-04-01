import '../credentials.dart';

typedef UserProfile = Map<String, dynamic>;

class LoginResult extends Credentials {
  final UserProfile userProfile;

  const LoginResult(
      {required final String idToken,
      required final String accessToken,
      final String? refreshToken,
      required final double expiresIn,
      final Set<String> scopes = const {},
      required this.userProfile})
      : super(
            idToken: idToken,
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            scopes: scopes);
  factory LoginResult.fromMap(final Map<String, dynamic> map) => LoginResult(
        userProfile: Map<String, dynamic>.from(
            map['userProfile'] as Map<dynamic, dynamic>),
        idToken: map['idToken'] as String,
        accessToken: map['accessToken'] as String,
        refreshToken: map['refreshToken'] as String?,
        expiresIn: map['expiresIn'] as double,
        scopes: Set<String>.from(map['scopes'] as List<Object?>),
      );
}
