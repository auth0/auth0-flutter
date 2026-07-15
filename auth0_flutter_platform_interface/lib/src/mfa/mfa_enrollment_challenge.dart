/// The result of initiating an MFA enrollment via one of the `MfaApi.enroll*`
/// methods.
///
/// This is a flattened superset of the factor-specific enrollment challenges
/// returned by the underlying native SDKs. Which fields are populated depends
/// on the factor:
///
/// - **TOTP** (`enrollTotp`): [totpSecret] and [barcodeUri] (render a QR code
///   from [barcodeUri]); plus [recoveryCodes] on first enrollment.
/// - **SMS/Voice & Email** (`enrollPhone`, `enrollEmail`): [oobCode],
///   [oobChannel] and [bindingMethod]. Confirm with `verifyOob`.
/// - **Push** (`enrollPush`): [oobCode], [oobChannel] and [barcodeUri] (scan
///   with the Guardian app).
class MfaEnrollmentChallenge {
  /// The underlying authenticator type, e.g. `oob` or `otp`.
  final String? authenticatorType;

  /// The out-of-band channel for OOB enrollments, e.g. `sms`, `email`,
  /// `auth0` (Push).
  ///
  /// Note: this is surfaced on iOS but is not exposed by the Android native
  /// SDK for phone/email enrollments, so it may be `null` on Android even for
  /// OOB factors.
  final String? oobChannel;

  /// The out-of-band code identifying this enrollment session, used to
  /// complete verification.
  final String? oobCode;

  /// How the out-of-band code is bound, e.g. `prompt` or `transfer`.
  final String? bindingMethod;

  /// The shared secret for TOTP enrollment, for manual entry into an
  /// authenticator app.
  final String? totpSecret;

  /// A URI (`otpauth://` for TOTP, or a Guardian URI for Push) to render as a
  /// QR code.
  final String? barcodeUri;

  /// Recovery codes issued on first enrollment of a new authenticator type.
  /// Store these securely and present them to the user.
  final List<String>? recoveryCodes;

  /// The enrollment identifier, when surfaced by the platform.
  final String? id;

  /// The authentication session, when surfaced by the platform.
  final String? authSession;

  const MfaEnrollmentChallenge({
    this.authenticatorType,
    this.oobChannel,
    this.oobCode,
    this.bindingMethod,
    this.totpSecret,
    this.barcodeUri,
    this.recoveryCodes,
    this.id,
    this.authSession,
  });

  factory MfaEnrollmentChallenge.fromMap(final Map<String, dynamic> result) =>
      MfaEnrollmentChallenge(
        authenticatorType: result['authenticator_type'] as String?,
        oobChannel: result['oob_channel'] as String?,
        oobCode: result['oob_code'] as String?,
        bindingMethod: result['binding_method'] as String?,
        totpSecret: result['totp_secret'] as String?,
        barcodeUri: result['barcode_uri'] as String?,
        recoveryCodes: (result['recovery_codes'] as List<Object?>?)
            ?.map((final e) => e as String)
            .toList(),
        id: result['id'] as String?,
        authSession: result['auth_session'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'authenticator_type': authenticatorType,
        'oob_channel': oobChannel,
        'oob_code': oobCode,
        'binding_method': bindingMethod,
        'totp_secret': totpSecret,
        'barcode_uri': barcodeUri,
        'recovery_codes': recoveryCodes,
        'id': id,
        'auth_session': authSession,
      };
}
