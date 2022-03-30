import '../credentials.dart';

typedef UserProfile = Map<String, Object>;

class LoginResult extends Credentials {
  final UserProfile userProfile;

  const LoginResult(
      {required final String idToken,
      required final String accessToken,
      final String? refreshToken,
      required final int expiresIn,
      final Set<String> scopes = const {},
      required this.userProfile})
      : super(
            idToken: idToken,
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            scopes: scopes);
}

// class WebAuthLoginResult {
//   final UserProfile userProfile;
//   final String idToken;
//   final String accessToken;
//   final String? refreshToken;
//   final int expiresIn;
//   final Set<String> scopes;

//   WebAuthLoginResult(
//       {required this.userProfile,
//       required this.idToken,
//       required this.accessToken,
//       this.refreshToken,
//       required this.expiresIn,
//       required this.scopes});
// }
