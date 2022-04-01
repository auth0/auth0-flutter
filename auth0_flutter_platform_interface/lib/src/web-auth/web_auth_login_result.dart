import '../credentials.dart';

typedef UserProfile = Map<String, dynamic>;

class LoginResult extends Credentials {
  final UserProfile userProfile;

  const LoginResult(
      {required final String idToken,
      required final String accessToken,
      final String? refreshToken,
      required final double expiresAt,
      final Set<String> scopes = const {},
      required this.userProfile})
      : super(
            idToken: idToken,
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
            scopes: scopes);
  factory LoginResult.fromMap(final Map<String, dynamic> result) => LoginResult(
        userProfile: Map<String, dynamic>.from(
            result['userProfile'] as Map<dynamic, dynamic>),
        idToken: result['idToken'] as String,
        accessToken: result['accessToken'] as String,
        refreshToken: result['refreshToken'] as String?,
        expiresIn: result['expiresIn'] as double,
        scopes: Set<String>.from(result['scopes'] as List<Object?>),
      );
}
