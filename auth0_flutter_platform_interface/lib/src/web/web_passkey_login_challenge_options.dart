/// Options for requesting a passkey login challenge on the web platform.
class WebPasskeyLoginChallengeOptions {
  final String? connection;
  final String? organization;

  WebPasskeyLoginChallengeOptions({
    this.connection,
    this.organization,
  });
}
