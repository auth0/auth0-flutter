/// A single MFA factor referenced in an `mfa_required` error's requirements,
/// e.g. `otp`, `phone`, `email`, `push-notification`, `recovery-code`.
class MfaFactor {
  final String type;

  const MfaFactor({required this.type});

  factory MfaFactor.fromMap(final Map<String, dynamic> result) =>
      MfaFactor(type: result['type'] as String);

  Map<String, dynamic> toMap() => {'type': type};
}

/// The factors a user can use or enroll, parsed from the `mfa_requirements`
/// field of an `mfa_required` error.
///
/// Use [challenge] to decide which authenticators can be challenged, and
/// [enroll] to decide which factors can be newly enrolled.
class MfaRequirements {
  /// Factors the user can be challenged with (already enrolled).
  final List<MfaFactor> challenge;

  /// Factors the user can enroll (no active authenticator yet).
  final List<MfaFactor> enroll;

  const MfaRequirements({
    this.challenge = const [],
    this.enroll = const [],
  });

  factory MfaRequirements.fromMap(final Map<String, dynamic> result) =>
      MfaRequirements(
        challenge: _parseFactors(result['challenge']),
        enroll: _parseFactors(result['enroll']),
      );

  static List<MfaFactor> _parseFactors(final Object? value) =>
      (value as List<Object?>?)
          ?.map((final e) =>
              MfaFactor.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [];

  Map<String, dynamic> toMap() => {
        'challenge': challenge.map((final f) => f.toMap()).toList(),
        'enroll': enroll.map((final f) => f.toMap()).toList(),
      };
}
