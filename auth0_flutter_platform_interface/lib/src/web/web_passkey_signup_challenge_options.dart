/// Options for requesting a passkey signup challenge on the web platform.
class WebPasskeySignupChallengeOptions {
  final String? email;
  final String? phoneNumber;
  final String? username;
  final String? name;
  final String? givenName;
  final String? familyName;
  final String? nickname;
  final String? picture;
  final String? realm;
  final String? organization;
  final Map<String, String>? userMetadata;

  WebPasskeySignupChallengeOptions({
    this.email,
    this.phoneNumber,
    this.username,
    this.name,
    this.givenName,
    this.familyName,
    this.nickname,
    this.picture,
    this.realm,
    this.organization,
    this.userMetadata,
  });
}
