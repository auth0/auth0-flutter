import '../request/request_options.dart';

/// The kind of credential being verified, which determines the MFA grant type
/// used in the token exchange.
enum MfaVerifyGrantType {
  /// One-time password (TOTP authenticator app). Uses the `mfa-otp` grant.
  otp,

  /// Out-of-band code (SMS, Email, Push). Uses the `mfa-oob` grant.
  oob,

  /// Recovery code. Uses the `mfa-recovery-code` grant.
  recoveryCode;

  String toValue() {
    switch (this) {
      case MfaVerifyGrantType.otp:
        return 'otp';
      case MfaVerifyGrantType.oob:
        return 'oob';
      case MfaVerifyGrantType.recoveryCode:
        return 'recovery_code';
    }
  }
}

/// Options for verifying an MFA challenge and exchanging it for credentials.
class MfaVerifyOptions implements RequestOptions {
  /// The `mfa_token` obtained from a `mfa_required` authentication error.
  final String mfaToken;

  /// The grant type to use for the verification, which selects which of
  /// [otp], [oobCode] or [recoveryCode] is required.
  final MfaVerifyGrantType grantType;

  /// Required when [grantType] is [MfaVerifyGrantType.otp].
  final String? otp;

  /// Required when [grantType] is [MfaVerifyGrantType.oob]. Obtained from the
  /// `oobCode` of the `MfaChallenge` returned by an MFA challenge.
  final String? oobCode;

  /// Optional binding code entered by the user when the challenge's
  /// `binding_method` is `prompt`. Only used when [grantType] is
  /// [MfaVerifyGrantType.oob].
  final String? bindingCode;

  /// Required when [grantType] is [MfaVerifyGrantType.recoveryCode].
  final String? recoveryCode;

  MfaVerifyOptions({
    required this.mfaToken,
    required this.grantType,
    this.otp,
    this.oobCode,
    this.bindingCode,
    this.recoveryCode,
  });

  @override
  Map<String, dynamic> toMap() => {
        'mfaToken': mfaToken,
        'grantType': grantType.toValue(),
        'otp': otp,
        'oobCode': oobCode,
        'bindingCode': bindingCode,
        'recoveryCode': recoveryCode,
      };
}
