class EnrollmentChallenge {
  final String id;
  final String authSession;
  final String? totpSecret;
  final String? totpUri;
  final String? barcodeUri;
  final String? recoveryCode;

  const EnrollmentChallenge({
    required this.id,
    required this.authSession,
    this.totpSecret,
    this.totpUri,
    this.barcodeUri,
    this.recoveryCode,
  });

  factory EnrollmentChallenge.fromMap(final Map<String, dynamic> result) =>
      EnrollmentChallenge(
        id: result['id'] as String,
        authSession: result['auth_session'] as String,
        totpSecret: result['totp_secret'] as String?,
        totpUri: result['totp_uri'] as String?,
        barcodeUri: result['barcode_uri'] as String?,
        recoveryCode: result['recovery_code'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'auth_session': authSession,
        'totp_secret': totpSecret,
        'totp_uri': totpUri,
        'barcode_uri': barcodeUri,
        'recovery_code': recoveryCode,
      };
}
