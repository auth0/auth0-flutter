/// A challenge issued by Auth0 to begin a passkey signup.
///
/// Returned by `passkeySignupChallenge`. Use it to present the OS passkey
/// creation UI in your app, then pass it together with the resulting credential
/// to `passkeySignup` to exchange them for tokens.
class PasskeySignupChallenge {
  /// The authentication session token that ties the challenge to the
  /// subsequent token exchange.
  final String authSession;

  /// The WebAuthn public-key creation options (e.g. `challenge`, `rpId`,
  /// `userId`, `userName`) used to drive the platform authenticator.
  final Map<String, dynamic> authParamsPublicKey;

  const PasskeySignupChallenge({
    required this.authSession,
    required this.authParamsPublicKey,
  });

  factory PasskeySignupChallenge.fromMap(final Map<dynamic, dynamic> result) =>
      PasskeySignupChallenge(
        authSession: result['authSession'] as String,
        authParamsPublicKey: Map<String, dynamic>.from(
            result['authParamsPublicKey'] as Map<dynamic, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'authSession': authSession,
        'authParamsPublicKey': authParamsPublicKey,
      };
}
