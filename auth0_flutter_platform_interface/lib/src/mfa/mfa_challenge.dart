/// The result of initiating an MFA challenge via `MfaApi.challenge`.
class MfaChallenge {
  /// The type of challenge, e.g. `oob` or `otp`.
  final String challengeType;

  /// The out-of-band code identifying this challenge session. Pass it to
  /// `MfaApi.verifyOob` to complete the challenge. `null` for `otp`
  /// challenges, which are verified directly with the user-entered code.
  final String? oobCode;

  /// How the out-of-band code is bound, e.g. `prompt` (the user must enter a
  /// binding code received via the channel) or `transfer`. `null` when not
  /// applicable.
  final String? bindingMethod;

  const MfaChallenge({
    required this.challengeType,
    this.oobCode,
    this.bindingMethod,
  });

  factory MfaChallenge.fromMap(final Map<String, dynamic> result) =>
      MfaChallenge(
        challengeType: result['challenge_type'] as String,
        oobCode: result['oob_code'] as String?,
        bindingMethod: result['binding_method'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'challenge_type': challengeType,
        'oob_code': oobCode,
        'binding_method': bindingMethod,
      };
}
