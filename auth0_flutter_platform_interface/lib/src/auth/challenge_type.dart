const String _otp = 'otp';
const String _oob = 'oob';

/// How the user will get the multi-factor authentication challenge and prove
/// possession.
enum ChallengeType {
  /// One-time password (OTP).
  otp(_otp),

  /// SMS/voice messages or out-of-band (OOB).
  oob(_oob);

  const ChallengeType(this.value);

  factory ChallengeType.fromString(final String value) {
    switch (value) {
      case _otp:
        return ChallengeType.otp;
      case _oob:
        return ChallengeType.oob;
      default:
        throw ArgumentError('Unexpected challenge_type value: $value');
    }
  }

  /// String value for the current enum case.
  final String value;
}
