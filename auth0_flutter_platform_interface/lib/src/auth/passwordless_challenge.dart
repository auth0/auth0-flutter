/// A challenge issued by Auth0 when starting a passwordless OTP flow against a
/// database connection.
///
/// Returned by `challengeWithEmail` or `challengeWithPhoneNumber`. It holds the
/// opaque [authSession] that ties the challenge to the subsequent OTP token
/// exchange performed by `loginWithOtp`.
///
/// Treat [authSession] as opaque: do not parse, log, or persist it beyond the
/// in-flight flow.
class PasswordlessChallenge {
  /// The opaque authentication session that binds this challenge to the
  /// subsequent OTP token exchange.
  final String authSession;

  const PasswordlessChallenge({required this.authSession});

  factory PasswordlessChallenge.fromMap(final Map<dynamic, dynamic> result) =>
      PasswordlessChallenge(authSession: result['authSession'] as String);

  Map<String, dynamic> toMap() => {'authSession': authSession};
}
