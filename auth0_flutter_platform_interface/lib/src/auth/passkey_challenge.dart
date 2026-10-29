import 'passkey_verification_method.dart';

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

  /// The identifiers that must be verified with a one-time code before tokens
  /// are issued, or `null` when no verification is required.
  ///
  /// Only set on a signup challenge when identifier verification is enabled
  /// for the connection. Collect a code for each identifier **before**
  /// creating the passkey, and pass them as `verification` to
  /// `passkeyCredentialExchange`.
  ///
  /// To retry after a wrong code, build a new [PasskeyChallenge] with the
  /// `passkeyAuthSession` and `passkeyVerificationRequired` of the
  /// `ApiException`, and the same [authParamsPublicKey].
  final List<PasskeyVerificationMethod>? verificationRequired;

  const PasskeyChallenge({
    required this.authSession,
    required this.authParamsPublicKey,
    this.verificationRequired,
  });

  factory PasskeyChallenge.fromMap(final Map<dynamic, dynamic> result) {
    final verificationRequired = result['verificationRequired'];

    return PasskeyChallenge(
      authSession: result['authSession'] as String,
      authParamsPublicKey: Map<String, dynamic>.from(
          result['authParamsPublicKey'] as Map<dynamic, dynamic>),
      verificationRequired: verificationRequired is List
          ? PasskeyVerificationMethod.fromValues(verificationRequired)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'authSession': authSession,
        'authParamsPublicKey': authParamsPublicKey,
        if (verificationRequired != null)
          'verificationRequired':
              verificationRequired!.map((final m) => m.value).toList(),
      };
}
