import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

/// An interface for completing Multi-Factor Authentication (MFA) flows on the
/// web using an `mfa_token`, as part of Auth0's
/// [flexible/expanded grant support](https://auth0.com/docs/secure/multi-factor-authentication).
///
/// When a token request fails because MFA is required, the resulting
/// [WebException] has `code == 'MFA_REQUIRED'` and carries the `mfa_token`
/// in its `details` map under the `mfaToken` key. Pass that token to
/// `Auth0Web.mfa(mfaToken:)` to obtain an instance of this class and drive the
/// challenge or enrollment flow.
///
/// This mirrors the mobile `MfaApi`, but is backed by the `auth0-spa-js`
/// programmatic MFA API (`Auth0Client.mfa`), which requires `auth0-spa-js`
/// v2.21.0 or later. Because the MFA context is stored on the same
/// `Auth0Client` that produced the `mfa_required` error, you must call these
/// methods on the same `Auth0Web` instance that triggered MFA.
///
/// It is not intended for you to instantiate this class yourself; an instance
/// is available via `Auth0Web.mfa(mfaToken:)`.
///
/// ## Usage example
///
/// ```dart
/// final auth0 = Auth0Web('DOMAIN', 'CLIENT_ID');
///
/// try {
///   await auth0.credentials();
/// } on WebException catch (e) {
///   final mfaToken = e.details['mfaToken'] as String?;
///   if (e.code == 'MFA_REQUIRED' && mfaToken != null) {
///     final mfa = auth0.mfa(mfaToken: mfaToken);
///
///     final authenticators = await mfa.getAuthenticators();
///     final challenge = await mfa.challenge(
///       authenticatorId: authenticators.first.id,
///     );
///
///     // For OTP factors, collect the code from the user, then:
///     final credentials = await mfa.verifyOtp(otp: '123456');
///   }
/// }
/// ```
class MfaWeb {
  final String _mfaToken;

  MfaWeb(this._mfaToken);

  /// Lists the authenticators that can be used with the current `mfa_token`.
  ///
  /// The results are filtered to the factors allowed by the `mfa_token`'s
  /// `mfa_requirements`.
  ///
  /// **Note:** unlike the mobile API, `auth0-spa-js` does not accept a
  /// client-side `factorsAllowed` filter, so that parameter is not exposed
  /// here.
  Future<List<MfaAuthenticator>> getAuthenticators() =>
      Auth0FlutterWebPlatform.instance.mfaGetAuthenticators(_mfaToken);

  /// Enrolls a new TOTP (authenticator app) factor.
  ///
  /// Returns an [MfaEnrollmentChallenge] whose `barcodeUri` and `totpSecret`
  /// you present to the user (typically as a QR code). After the user adds the
  /// account in their authenticator app, complete enrollment with [verifyOtp].
  Future<MfaEnrollmentChallenge> enrollTotp() =>
      Auth0FlutterWebPlatform.instance.mfaEnrollTotp(_mfaToken);

  /// Enrolls a new phone (SMS or Voice) factor for the given [phoneNumber].
  ///
  /// Returns an [MfaEnrollmentChallenge] containing the `oobCode` used to
  /// complete verification via [verifyOob] once the user receives the code.
  Future<MfaEnrollmentChallenge> enrollPhone({
    required final String phoneNumber,
    final PhoneType type = PhoneType.sms,
  }) =>
      Auth0FlutterWebPlatform.instance
          .mfaEnrollPhone(_mfaToken, phoneNumber, type);

  /// Enrolls a new email factor for the given [email] address.
  ///
  /// Returns an [MfaEnrollmentChallenge] containing the `oobCode` used to
  /// complete verification via [verifyOob] once the user receives the code.
  Future<MfaEnrollmentChallenge> enrollEmail({required final String email}) =>
      Auth0FlutterWebPlatform.instance.mfaEnrollEmail(_mfaToken, email);

  /// Enrolls a new push notification factor (Auth0 Guardian).
  ///
  /// Returns an [MfaEnrollmentChallenge] whose `barcodeUri` you present to the
  /// user to scan with the Guardian app.
  Future<MfaEnrollmentChallenge> enrollPush() =>
      Auth0FlutterWebPlatform.instance.mfaEnrollPush(_mfaToken);

  /// Initiates a challenge for the authenticator identified by
  /// [authenticatorId] (obtained from [getAuthenticators]).
  ///
  /// For out-of-band factors (SMS, Email, Push) this triggers delivery of the
  /// code and returns an [MfaChallenge] whose `oobCode` you pass to
  /// [verifyOob]. For TOTP, verify directly with [verifyOtp].
  Future<MfaChallenge> challenge({required final String authenticatorId}) =>
      Auth0FlutterWebPlatform.instance
          .mfaChallenge(_mfaToken, authenticatorId);

  /// Verifies a one-time password ([otp]) for a TOTP authenticator and
  /// exchanges the `mfa_token` for [Credentials].
  Future<Credentials> verifyOtp({required final String otp}) =>
      Auth0FlutterWebPlatform.instance.mfaVerify(
          _mfaToken,
          MfaVerifyOptions(
              mfaToken: _mfaToken,
              grantType: MfaVerifyGrantType.otp,
              otp: otp));

  /// Verifies an out-of-band challenge (SMS, Email, Push) and exchanges the
  /// `mfa_token` for [Credentials].
  ///
  /// [oobCode] comes from the [MfaChallenge] returned by [challenge] (or the
  /// [MfaEnrollmentChallenge] returned by an enrollment). Provide [bindingCode]
  /// when the challenge's `bindingMethod` is `prompt`.
  Future<Credentials> verifyOob({
    required final String oobCode,
    final String? bindingCode,
  }) =>
      Auth0FlutterWebPlatform.instance.mfaVerify(
          _mfaToken,
          MfaVerifyOptions(
              mfaToken: _mfaToken,
              grantType: MfaVerifyGrantType.oob,
              oobCode: oobCode,
              bindingCode: bindingCode));

  /// Verifies a [recoveryCode] and exchanges the `mfa_token` for [Credentials].
  Future<Credentials> verifyRecoveryCode(
          {required final String recoveryCode}) =>
      Auth0FlutterWebPlatform.instance.mfaVerify(
          _mfaToken,
          MfaVerifyOptions(
              mfaToken: _mfaToken,
              grantType: MfaVerifyGrantType.recoveryCode,
              recoveryCode: recoveryCode));
}
