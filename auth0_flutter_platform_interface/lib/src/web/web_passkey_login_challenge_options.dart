/// Options for requesting a passkey login challenge on the web platform.
class WebPasskeyLoginChallengeOptions {
  final String? realm;
  final String? organization;

  WebPasskeyLoginChallengeOptions({
    this.realm,
    this.organization,
  });
}
