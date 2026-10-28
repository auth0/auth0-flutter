/// An identifier whose ownership must be verified with a one-time code before a
/// passkey signup can complete.
///
/// Returned in `PasskeyChallenge.verificationRequired` and on a retryable
/// passkey verification error. Use it as the key when passing the collected
/// codes in the `verification` map of `passkeyCredentialExchange`.
enum PasskeyVerificationMethod {
  /// The user's email address.
  email('email'),

  /// The user's phone number.
  phone('phone');

  /// The value used by the Auth0 Authentication API, e.g. `"email"`.
  final String value;

  const PasskeyVerificationMethod(this.value);

  /// Converts a list of raw identifier values to [PasskeyVerificationMethod]s.
  ///
  /// Values that this version of the SDK doesn't know are dropped.
  static List<PasskeyVerificationMethod> fromValues(
          final Iterable<dynamic> values) =>
      [
        for (final value in values)
          for (final method in PasskeyVerificationMethod.values)
            if (method.value == value) method,
      ];
}
