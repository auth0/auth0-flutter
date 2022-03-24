class WebAuthLoginResult {
  late String userProfile;
  late String idToken;
  late String accessToken;
  late String refreshToken;
  late String expiresIn;
  late String scopes;

  WebAuthLoginResult(
      this.userProfile,
      this.idToken,
      this.accessToken,
      this.refreshToken,
      this.expiresIn,
      this.scopes);
}
