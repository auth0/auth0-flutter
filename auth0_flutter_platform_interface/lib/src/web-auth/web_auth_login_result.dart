class UserProfile {
  late String name;
  UserProfile(this.name);
}

class WebAuthLoginResult {
  late UserProfile userProfile;
  late String idToken;
  late String accessToken;
  late String refreshToken;
  late int expiresIn;
  late Set<String> scopes;

  WebAuthLoginResult(
      {required final UserProfile userProfile,
      required final String idToken,
      required final String accessToken,
      required final String refreshToken,
      required final int expiresIn,
      required final Set<String> scopes}) {
    this.userProfile = userProfile;
    this.idToken = idToken;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.expiresIn = expiresIn;
    this.scopes = scopes;
  }
}
