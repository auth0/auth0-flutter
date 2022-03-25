class UserProfile {
  late String name;
  UserProfile(this.name);
}

class WebAuthLoginResult {
  final UserProfile userProfile;
  final String idToken;
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final Set<String> scopes;

  WebAuthLoginResult(
      {required this.userProfile,
      required this.idToken,
      required this.accessToken,
      this.refreshToken,
      required expiresIn,
      required scopes});
}
