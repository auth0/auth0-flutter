import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

/// An interface for interacting with the
/// [Auth0 My Account API](https://auth0.com/docs/manage-users/my-account-api).
///
/// This class enables end-users to self-manage their authentication methods
/// (MFA factors) without requiring Management API tokens.
///
/// It is not intended for you to instantiate this class yourself, as an
/// instance of it is available via `Auth0.myAccount(accessToken:)`.
///
/// **Note:** This API is only supported on mobile platforms (Android/iOS).
/// Web is not supported.
///
/// Usage example:
///
/// ```dart
/// final auth0 = Auth0('DOMAIN', 'CLIENT_ID');
/// final myAccount = auth0.myAccount(accessToken: 'ACCESS_TOKEN');
///
/// final methods = await myAccount.getAuthenticationMethods();
/// ```
class MyAccountApi {
  final Account _account;
  final UserAgent _userAgent;
  final String _accessToken;
  final bool _useDPoP;

  MyAccountApi(this._account, this._userAgent, this._accessToken,
      {final bool useDPoP = false})
      : _useDPoP = useDPoP;

  /// Lists all authentication methods enrolled by the user.
  ///
  /// Optionally filter the results by [type] (e.g.
  /// [AuthenticationMethodType.phone]).
  ///
  /// Requires an access token with the `read:me:authentication_methods` scope
  /// and audience `https://{domain}/me/`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final methods = await myAccount.getAuthenticationMethods();
  ///
  /// // Filtered by type
  /// final phones = await myAccount.getAuthenticationMethods(
  ///   type: AuthenticationMethodType.phone,
  /// );
  /// ```
  Future<List<AuthenticationMethod>> getAuthenticationMethods(
          {final AuthenticationMethodType? type}) =>
      Auth0FlutterMyAccountPlatform.instance.getAuthenticationMethods(
          _createApiRequest(MyAccountGetAuthMethodsOptions(
              accessToken: _accessToken, type: type)));

  /// Gets a specific authentication method by [id].
  ///
  /// Requires an access token with the `read:me:authentication_methods` scope
  /// and audience `https://{domain}/me/`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final method = await myAccount.getAuthenticationMethod(
  ///   id: 'auth_method_id',
  /// );
  /// ```
  Future<AuthenticationMethod> getAuthenticationMethod(
          {required final String id}) =>
      Auth0FlutterMyAccountPlatform.instance.getAuthenticationMethod(
          _createApiRequest(MyAccountGetAuthMethodOptions(
              accessToken: _accessToken, id: id)));

  /// Deletes an authentication method by [id].
  ///
  /// Requires an access token with the `delete:me:authentication_methods`
  /// scope and audience `https://{domain}/me/`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// await myAccount.deleteAuthenticationMethod(id: 'auth_method_id');
  /// ```
  Future<void> deleteAuthenticationMethod({required final String id}) =>
      Auth0FlutterMyAccountPlatform.instance.deleteAuthenticationMethod(
          _createApiRequest(MyAccountDeleteAuthMethodOptions(
              accessToken: _accessToken, id: id)));

  /// Lists the factors available for enrollment on the tenant.
  ///
  /// Requires an access token with the `read:me:factors` scope
  /// and audience `https://{domain}/me/`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final factors = await myAccount.getFactors();
  /// ```
  Future<List<Factor>> getFactors() =>
      Auth0FlutterMyAccountPlatform.instance.getFactors(_createApiRequest(
          MyAccountGetFactorsOptions(accessToken: _accessToken)));

  /// Initiates phone enrollment with the specified [phoneNumber] and [type].
  ///
  /// Returns an [EnrollmentChallenge] containing the enrollment `id` and
  /// `authSession` needed to complete verification via [verifyOtp].
  ///
  /// Requires an access token with the `create:me:authentication_methods`
  /// scope and audience `https://{domain}/me/`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final challenge = await myAccount.enrollPhone(
  ///   phoneNumber: '+1234567890',
  ///   type: PhoneType.sms,
  /// );
  /// ```
  Future<EnrollmentChallenge> enrollPhone({
    required final String phoneNumber,
    required final PhoneType type,
  }) =>
      Auth0FlutterMyAccountPlatform.instance.enrollPhone(_createApiRequest(
          MyAccountEnrollPhoneOptions(
              accessToken: _accessToken,
              phoneNumber: phoneNumber,
              type: type)));

  /// Initiates email enrollment with the specified [email] address.
  ///
  /// Returns an [EnrollmentChallenge] containing the enrollment `id` and
  /// `authSession` needed to complete verification via [verifyOtp].
  ///
  /// Requires an access token with the `create:me:authentication_methods`
  /// scope and audience `https://{domain}/me/`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final challenge = await myAccount.enrollEmail(
  ///   email: 'user@example.com',
  /// );
  /// ```
  Future<EnrollmentChallenge> enrollEmail({required final String email}) =>
      Auth0FlutterMyAccountPlatform.instance.enrollEmail(_createApiRequest(
          MyAccountEnrollEmailOptions(
              accessToken: _accessToken, email: email)));

  /// Initiates TOTP (authenticator app) enrollment.
  ///
  /// Returns an [EnrollmentChallenge] containing the `totpSecret` and
  /// `totpUri` for the authenticator app, along with `id` and `authSession`
  /// needed to complete verification via [verifyOtp].
  ///
  /// Requires an access token with the `create:me:authentication_methods`
  /// scope and audience `https://{domain}/me/`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final challenge = await myAccount.enrollTotp();
  /// // Use challenge.totpUri to display a QR code
  /// ```
  Future<EnrollmentChallenge> enrollTotp() =>
      Auth0FlutterMyAccountPlatform.instance.enrollTotp(
          _createApiRequest(MyAccountEnrollTotpOptions(
              accessToken: _accessToken)));

  /// Initiates push notification enrollment.
  ///
  /// Returns an [EnrollmentChallenge] containing the enrollment `id` and
  /// `authSession` needed to complete the enrollment via [confirmEnrollment].
  ///
  /// Requires an access token with the `create:me:authentication_methods`
  /// scope and audience `https://{domain}/me/`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final challenge = await myAccount.enrollPush();
  /// ```
  Future<EnrollmentChallenge> enrollPush() =>
      Auth0FlutterMyAccountPlatform.instance.enrollPush(
          _createApiRequest(MyAccountEnrollPushOptions(
              accessToken: _accessToken)));

  /// Initiates recovery code enrollment.
  ///
  /// Returns an [EnrollmentChallenge] containing the `recoveryCode`.
  ///
  /// Requires an access token with the `create:me:authentication_methods`
  /// scope and audience `https://{domain}/me/`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final challenge = await myAccount.enrollRecoveryCode();
  /// // Store challenge.recoveryCode securely
  /// ```
  Future<EnrollmentChallenge> enrollRecoveryCode() =>
      Auth0FlutterMyAccountPlatform.instance.enrollRecoveryCode(
          _createApiRequest(MyAccountEnrollRecoveryCodeOptions(
              accessToken: _accessToken)));

  /// Verifies an enrollment using a one-time password [otp].
  ///
  /// Use this after calling an enrollment method (e.g., [enrollPhone],
  /// [enrollEmail], [enrollTotp]) to confirm the enrollment.
  ///
  /// [factorType] must match the enrolled factor: `"phone"`, `"email"`, or
  /// `"totp"`. This is used on iOS to dispatch to the correct Auth0.swift
  /// confirm method.
  ///
  /// Returns the confirmed [AuthenticationMethod] after successful
  /// verification.
  ///
  /// [id] and [authSession] are obtained from the [EnrollmentChallenge]
  /// returned by the enrollment method.
  ///
  /// Requires an access token with the `create:me:authentication_methods`
  /// scope and audience `https://{domain}/me/`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final method = await myAccount.verifyOtp(
  ///   id: challenge.id,
  ///   authSession: challenge.authSession,
  ///   otp: '123456',
  ///   factorType: 'totp',
  /// );
  /// ```
  Future<AuthenticationMethod> verifyOtp({
    required final String id,
    required final String authSession,
    required final String otp,
    required final String factorType,
  }) =>
      Auth0FlutterMyAccountPlatform.instance.verifyOtp(_createApiRequest(
          MyAccountVerifyOtpOptions(
              accessToken: _accessToken,
              id: id,
              authSession: authSession,
              otp: otp,
              factorType: factorType)));

  /// Confirms an enrollment that does not require a one-time password, namely
  /// push notification and recovery code enrollments.
  ///
  /// Use this after calling [enrollPush] or [enrollRecoveryCode]. For factors
  /// that require an OTP (phone, email, TOTP), use [verifyOtp] instead.
  ///
  /// [factorType] must be `"push-notification"` or `"recovery-code"`. This is
  /// used on iOS to dispatch to the correct Auth0.swift confirm method.
  ///
  /// Returns the confirmed [AuthenticationMethod] after successful
  /// confirmation.
  ///
  /// [id] and [authSession] are obtained from the [EnrollmentChallenge]
  /// returned by the enrollment method.
  ///
  /// Requires an access token with the `create:me:authentication_methods`
  /// scope and audience `https://{domain}/me/`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final method = await myAccount.confirmEnrollment(
  ///   id: challenge.id,
  ///   authSession: challenge.authSession,
  ///   factorType: 'push-notification',
  /// );
  /// ```
  Future<AuthenticationMethod> confirmEnrollment({
    required final String id,
    required final String authSession,
    required final String factorType,
  }) =>
      Auth0FlutterMyAccountPlatform.instance.confirmEnrollment(
          _createApiRequest(MyAccountConfirmEnrollmentOptions(
              accessToken: _accessToken,
              id: id,
              authSession: authSession,
              factorType: factorType)));

  /// Updates an existing authentication method identified by [id].
  ///
  /// Pass a new [name] to rename the method, and/or a new
  /// [preferredAuthenticationMethod] (SMS or voice) for phone authenticators.
  /// Omitted parameters are left unchanged.
  ///
  /// Returns the updated [AuthenticationMethod].
  ///
  /// Requires an access token with the `update:me:authentication_methods`
  /// scope and audience `https://{domain}/me/`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final method = await myAccount.updateAuthenticationMethod(
  ///   id: 'auth_method_id',
  ///   name: 'My phone',
  ///   preferredAuthenticationMethod: PhoneType.voice,
  /// );
  /// ```
  Future<AuthenticationMethod> updateAuthenticationMethod({
    required final String id,
    final String? name,
    final PhoneType? preferredAuthenticationMethod,
  }) =>
      Auth0FlutterMyAccountPlatform.instance.updateAuthenticationMethod(
          _createApiRequest(MyAccountUpdateAuthMethodOptions(
              accessToken: _accessToken,
              id: id,
              name: name,
              preferredAuthenticationMethod: preferredAuthenticationMethod)));

  ApiRequest<TOptions> _createApiRequest<TOptions extends RequestOptions>(
          final TOptions options) =>
      ApiRequest<TOptions>(
          account: _account,
          options: options,
          userAgent: _userAgent,
          useDPoP: _useDPoP);
}
