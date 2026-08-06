/// A passkey challenge issued by Auth0 on the web platform.
///
/// Returned by `Auth0Web.passkeyLoginChallenge` (for an existing user) or
/// `Auth0Web.passkeySignupChallenge` (for a new user). Unlike the mobile
/// `PasskeyChallenge`, [authParamsPublicKey] is not a JSON map:
/// `auth0-spa-js` decodes the challenge into a browser-ready
/// `PublicKeyCredentialCreationOptions` (signup) or
/// `PublicKeyCredentialRequestOptions` (login) object, which is carried here
/// as-is. Cast it to the matching type from `package:web` before passing it
/// to `navigator.credentials.create()`/`.get()`.
class WebPasskeyChallenge {
  /// The authentication session token that ties the challenge to the
  /// subsequent token exchange via `Auth0Web.getTokenByPasskey`.
  final String authSession;

  /// The WebAuthn public-key options, decoded and ready to pass directly to
  /// `navigator.credentials.create()` (signup) or `navigator.credentials.get()`
  /// (login).
  final Object authParamsPublicKey;

  const WebPasskeyChallenge({
    required this.authSession,
    required this.authParamsPublicKey,
  });
}
