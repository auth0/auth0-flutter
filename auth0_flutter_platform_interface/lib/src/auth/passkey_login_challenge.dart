/// A challenge issued by Auth0 to begin a passkey login.
///
/// Returned by `passkeyLoginChallenge`. Use it to present the OS passkey UI in
/// your app, then pass it together with the resulting credential to
/// `passkeyLogin` to exchange them for tokens.
class PasskeyLoginChallenge {
  /// The authentication session token that ties the challenge to the
  /// subsequent token exchange.
  final String authSession;

  /// The WebAuthn public-key request options (e.g. `challenge`, `rpId`) used to
  /// drive the platform authenticator.
  final Map<String, dynamic> authParamsPublicKey;

  const PasskeyLoginChallenge({
    required this.authSession,
    required this.authParamsPublicKey,
  });

  factory PasskeyLoginChallenge.fromMap(final Map<dynamic, dynamic> result) =>
      PasskeyLoginChallenge(
        authSession: result['authSession'] as String,
        authParamsPublicKey: Map<String, dynamic>.from(
            result['authParamsPublicKey'] as Map<dynamic, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'authSession': authSession,
        'authParamsPublicKey': authParamsPublicKey,
      };
}
