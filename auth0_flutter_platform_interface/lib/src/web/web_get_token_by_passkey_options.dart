/// Options for exchanging a passkey credential response for Auth0 tokens on
/// the web platform.
class WebGetTokenByPasskeyOptions {
  /// The auth session received from the challenge response.
  final String authSession;

  /// The credential response from the browser's WebAuthn API.
  ///
  /// Pass the raw `PublicKeyCredential` object returned directly by
  /// `navigator.credentials.create()`/`.get()` — it does not need to be
  /// serialized first.
  final dynamic authResponse;

  /// The database connection name.
  final String? connection;

  /// The target API identifier for the issued access token.
  final String? audience;

  /// The scopes to request for the issued access token.
  final Set<String>? scopes;

  /// The optional Auth0 organization to authenticate with.
  final String? organization;

  WebGetTokenByPasskeyOptions({
    required this.authSession,
    required this.authResponse,
    this.connection,
    this.audience,
    this.scopes,
    this.organization,
  });
}
