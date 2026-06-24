import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

/// An interface for completing Multi-Factor Authentication (MFA) flows using
/// an `mfa_token`, as part of Auth0's
/// [flexible/expanded grant support](https://auth0.com/docs/secure/multi-factor-authentication).
///
/// When a token request fails because MFA is required, the resulting
/// [ApiException] exposes [ApiException.mfaToken] (and
/// [ApiException.mfaRequirements]). Pass that token to `Auth0.mfa(mfaToken:)`
/// to obtain an instance of this class and drive the challenge or enrollment
/// flow.
///
/// It is not intended for you to instantiate this class yourself; an instance
/// is available via `Auth0.mfa(mfaToken:)`.
///
/// **Note:** This class drives MFA on mobile platforms (Android/iOS). MFA is
/// also supported on the Web via `Auth0Web.mfa`; Windows is not supported.
///
/// ## Usage example
///
/// ```dart
/// final auth0 = Auth0('DOMAIN', 'CLIENT_ID');
///
/// try {
///   await auth0.api.renewCredentials(refreshToken: refreshToken);
/// } on ApiException catch (e) {
///   if (e.isMultifactorRequired && e.mfaToken != null) {
///     final mfa = auth0.mfa(mfaToken: e.mfaToken!);
///
///     final authenticators =
///         await mfa.getAuthenticators(factorsAllowed: ['otp', 'oob']);
///     final challenge = await mfa.challenge(
///       authenticatorId: authenticators.first.id,
///     );
///
///     // For OTP factors, collect the code from the user, then:
///     final credentials = await mfa.verifyOtp(otp: '123456');
///   }
/// }
/// ```
class MfaApi {
  final Account _account;
  final UserAgent _userAgent;
  final String _mfaToken;

  MfaApi(this._account, this._userAgent, this._mfaToken);

  /// Lists the authenticators that can be used with the current `mfa_token`.
  ///
  /// [factorsAllowed] is the list of factor types to return (e.g.
  /// `['otp', 'oob']`) and must contain at least one factor type — the
  /// underlying native SDKs reject an empty list with an `invalid_request`
  /// error.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final authenticators =
  ///     await mfa.getAuthenticators(factorsAllowed: ['otp', 'oob']);
  /// ```
  Future<List<MfaAuthenticator>> getAuthenticators(
          {required final List<String> factorsAllowed}) =>
      Auth0FlutterMfaPlatform.instance.getAuthenticators(_createApiRequest(
          MfaGetAuthenticatorsOptions(
              mfaToken: _mfaToken, factorsAllowed: factorsAllowed)));

  /// Enrolls a new TOTP (authenticator app) factor.
  ///
  /// Returns an [MfaEnrollmentChallenge] whose `barcodeUri` and `totpSecret`
  /// you present to the user (typically as a QR code). After the user adds the
  /// account in their authenticator app, complete enrollment with
  /// [verifyOtp].
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final challenge = await mfa.enrollTotp();
  /// // Render challenge.barcodeUri as a QR code, then:
  /// final credentials = await mfa.verifyOtp(otp: '123456');
  /// ```
  Future<MfaEnrollmentChallenge> enrollTotp() =>
      Auth0FlutterMfaPlatform.instance.enrollTotp(
          _createApiRequest(MfaEnrollTotpOptions(mfaToken: _mfaToken)));

  /// Enrolls a new phone (SMS) factor for the given [phoneNumber].
  ///
  /// Returns an [MfaEnrollmentChallenge] containing the `oobCode` used to
  /// complete verification via [verifyOob] once the user receives the code.
  ///
  /// **Note:** the underlying native SDKs only support the SMS out-of-band
  /// channel for phone enrollment (they always request
  /// `oob_channels: ['sms']`), so there is no option to select a voice channel
  /// here. Voice enrollment is available on the Web (`Auth0Web.mfa`) only.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final challenge = await mfa.enrollPhone(phoneNumber: '+1234567890');
  /// final credentials = await mfa.verifyOob(
  ///   oobCode: challenge.oobCode!,
  ///   bindingCode: '123456',
  /// );
  /// ```
  Future<MfaEnrollmentChallenge> enrollPhone({
    required final String phoneNumber,
  }) =>
      Auth0FlutterMfaPlatform.instance.enrollPhone(_createApiRequest(
          MfaEnrollPhoneOptions(
              mfaToken: _mfaToken, phoneNumber: phoneNumber)));

  /// Enrolls a new email factor for the given [email] address.
  ///
  /// Returns an [MfaEnrollmentChallenge] containing the `oobCode` used to
  /// complete verification via [verifyOob] once the user receives the code.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final challenge = await mfa.enrollEmail(email: 'user@example.com');
  /// ```
  Future<MfaEnrollmentChallenge> enrollEmail({required final String email}) =>
      Auth0FlutterMfaPlatform.instance.enrollEmail(_createApiRequest(
          MfaEnrollEmailOptions(mfaToken: _mfaToken, email: email)));

  /// Enrolls a new push notification factor (Auth0 Guardian).
  ///
  /// Returns an [MfaEnrollmentChallenge] whose `barcodeUri` you present to the
  /// user to scan with the Guardian app.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final challenge = await mfa.enrollPush();
  /// ```
  Future<MfaEnrollmentChallenge> enrollPush() =>
      Auth0FlutterMfaPlatform.instance.enrollPush(
          _createApiRequest(MfaEnrollPushOptions(mfaToken: _mfaToken)));

  /// Initiates a challenge for the authenticator identified by
  /// [authenticatorId] (obtained from [getAuthenticators]).
  ///
  /// For out-of-band factors (SMS, Email, Push) this triggers delivery of the
  /// code and returns an [MfaChallenge] whose `oobCode` you pass to
  /// [verifyOob]. For TOTP, verify directly with [verifyOtp].
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final challenge = await mfa.challenge(
  ///   authenticatorId: authenticators.first.id,
  /// );
  /// ```
  Future<MfaChallenge> challenge({required final String authenticatorId}) =>
      Auth0FlutterMfaPlatform.instance.challenge(_createApiRequest(
          MfaChallengeOptions(
              mfaToken: _mfaToken, authenticatorId: authenticatorId)));

  /// Verifies a one-time password ([otp]) for a TOTP authenticator and
  /// exchanges the `mfa_token` for [Credentials].
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final credentials = await mfa.verifyOtp(otp: '123456');
  /// ```
  Future<Credentials> verifyOtp({required final String otp}) =>
      Auth0FlutterMfaPlatform.instance.verify(_createApiRequest(
          MfaVerifyOptions(
              mfaToken: _mfaToken,
              grantType: MfaVerifyGrantType.otp,
              otp: otp)));

  /// Verifies an out-of-band challenge (SMS, Email, Push) and exchanges the
  /// `mfa_token` for [Credentials].
  ///
  /// [oobCode] comes from the [MfaChallenge] returned by [challenge] (or the
  /// [MfaEnrollmentChallenge] returned by an enrollment). Provide
  /// [bindingCode] when the challenge's `bindingMethod` is `prompt` (i.e. the
  /// user must enter a code received via the channel).
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final credentials = await mfa.verifyOob(
  ///   oobCode: challenge.oobCode!,
  ///   bindingCode: '123456',
  /// );
  /// ```
  Future<Credentials> verifyOob({
    required final String oobCode,
    final String? bindingCode,
  }) =>
      Auth0FlutterMfaPlatform.instance.verify(_createApiRequest(
          MfaVerifyOptions(
              mfaToken: _mfaToken,
              grantType: MfaVerifyGrantType.oob,
              oobCode: oobCode,
              bindingCode: bindingCode)));

  /// Verifies a [recoveryCode] and exchanges the `mfa_token` for
  /// [Credentials].
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final credentials = await mfa.verifyRecoveryCode(
  ///   recoveryCode: 'ABCD1234...',
  /// );
  /// ```
  Future<Credentials> verifyRecoveryCode(
          {required final String recoveryCode}) =>
      Auth0FlutterMfaPlatform.instance.verify(_createApiRequest(
          MfaVerifyOptions(
              mfaToken: _mfaToken,
              grantType: MfaVerifyGrantType.recoveryCode,
              recoveryCode: recoveryCode)));

  ApiRequest<TOptions> _createApiRequest<TOptions extends RequestOptions>(
          final TOptions options) =>
      ApiRequest<TOptions>(
          account: _account, options: options, userAgent: _userAgent);
}
