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
}
