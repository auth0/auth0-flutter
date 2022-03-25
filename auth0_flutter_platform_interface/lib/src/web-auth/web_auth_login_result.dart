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

  WebAuthLoginResult(this.userProfile, this.idToken, this.accessToken,
      this.refreshToken, this.expiresIn, this.scopes);
}
