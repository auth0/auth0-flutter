/// A challenge issued by Auth0 to begin a passkey ceremony.
///
/// Returned by `passkeyLoginChallenge` (for an existing user) or
/// `passkeySignupChallenge` (for a new user). Use it to present the OS passkey
/// UI in your app, then pass it together with the resulting credential to
/// `passkeyCredentialExchange` to exchange them for tokens.
class PasskeyChallenge {
  /// The authentication session token that ties the challenge to the
  /// subsequent token exchange.
  final String authSession;

  /// The WebAuthn public-key options (e.g. `challenge`, `rpId`, and — for
  /// signup — `userId`/`userName`) used to drive the platform authenticator.
  final Map<String, dynamic> authParamsPublicKey;

  const PasskeyChallenge({
    required this.authSession,
    required this.authParamsPublicKey,
  });

  factory PasskeyChallenge.fromMap(final Map<dynamic, dynamic> result) =>
      PasskeyChallenge(
        authSession: result['authSession'] as String,
        authParamsPublicKey: Map<String, dynamic>.from(
            result['authParamsPublicKey'] as Map<dynamic, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'authSession': authSession,
        'authParamsPublicKey': authParamsPublicKey,
      };
}
