/// A challenge issued by the My Account API to begin a passkey enrollment
/// ceremony.
///
/// Returned by `enrollPasskeyChallenge`. Use it to present the OS passkey
/// creation UI in your app, then pass it together with the resulting
/// credential to `enrollPasskey` to complete the enrollment.
class PasskeyEnrollmentChallenge {
  /// Unique identifier of the authentication method being enrolled. Needed to
  /// complete the enrollment via `enrollPasskey`.
  final String authenticationMethodId;

  /// The authentication session token that ties the challenge to the
  /// subsequent enrollment.
  final String authSession;

  /// The WebAuthn public-key creation options (e.g. `challenge`, `rp`,
  /// `user`, `pubKeyCredParams`) used to drive the platform authenticator.
  final Map<String, dynamic> authParamsPublicKey;

  const PasskeyEnrollmentChallenge({
    required this.authenticationMethodId,
    required this.authSession,
    required this.authParamsPublicKey,
  });

  factory PasskeyEnrollmentChallenge.fromMap(
          final Map<dynamic, dynamic> result) =>
      PasskeyEnrollmentChallenge(
        authenticationMethodId: result['authenticationMethodId'] as String,
        authSession: result['authSession'] as String,
        authParamsPublicKey: Map<String, dynamic>.from(
            result['authParamsPublicKey'] as Map<dynamic, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'authenticationMethodId': authenticationMethodId,
        'authSession': authSession,
        'authParamsPublicKey': authParamsPublicKey,
      };
}
