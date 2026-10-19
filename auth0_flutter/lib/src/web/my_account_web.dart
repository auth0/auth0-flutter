import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

/// An interface for interacting with the
/// [Auth0 My Account API](https://auth0.com/docs/manage-users/my-account-api)
/// on the web.
///
/// This class enables end-users to self-manage their authentication methods
/// (MFA factors) without requiring Management API tokens. It mirrors the mobile
/// `MyAccountApi`, but is backed by the `auth0-spa-js` `MyAccountApiClient`,
/// which requires `auth0-spa-js` v2.21.1 or later.
///
/// Every call is authorized with the access token passed to
/// `Auth0Web.myAccount(accessToken:)`. It must have the audience
/// `https://{domain}/me/` and the scopes required by each method. You can
/// obtain one with `Auth0Web.getApiCredentials`.
///
/// **Note:** When DPoP is enabled (`Auth0Web(useDPoP: true)`), requests are
/// sent with a DPoP proof signed by this `Auth0Web` instance's key, so the
/// access token must also have been issued to this same instance.
///
/// Failures are reported as a [MyAccountException], the same as on mobile.
///
/// It is not intended for you to instantiate this class yourself; an instance
/// is available via `Auth0Web.myAccount(accessToken:)`.
///
/// ## Usage example
///
/// ```dart
/// final auth0 = Auth0Web('DOMAIN', 'CLIENT_ID');
///
/// final apiCredentials = await auth0.getApiCredentials(
///   audience: 'https://DOMAIN/me/',
///   scopes: {'read:me:authentication_methods'},
/// );
/// final myAccount = auth0.myAccount(
///   accessToken: apiCredentials.accessToken,
/// );
///
/// final methods = await myAccount.getAuthenticationMethods();
/// ```
class MyAccountWeb {
  final String _accessToken;

  MyAccountWeb(this._accessToken);

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
          {AuthenticationMethodType? type}) =>
      Auth0FlutterWebPlatform.instance
          .getAuthenticationMethods(_accessToken, type);

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
  Future<AuthenticationMethod> getAuthenticationMethod({required String id}) =>
      Auth0FlutterWebPlatform.instance
          .getAuthenticationMethod(_accessToken, id);

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
  Future<void> deleteAuthenticationMethod({required String id}) =>
      Auth0FlutterWebPlatform.instance
          .deleteAuthenticationMethod(_accessToken, id);

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
      Auth0FlutterWebPlatform.instance.getFactors(_accessToken);

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
    required String phoneNumber,
    required PhoneType type,
  }) =>
      Auth0FlutterWebPlatform.instance
          .enrollPhone(_accessToken, phoneNumber, type);

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
  Future<EnrollmentChallenge> enrollEmail({required String email}) =>
      Auth0FlutterWebPlatform.instance.enrollEmail(_accessToken, email);

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
      Auth0FlutterWebPlatform.instance.enrollTotp(_accessToken);

  /// Initiates push notification enrollment.
  ///
  /// Returns an [EnrollmentChallenge] containing the `barcodeUri` to scan with
  /// the Guardian app, along with `id` and `authSession` needed to complete the
  /// enrollment via [confirmEnrollment].
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
      Auth0FlutterWebPlatform.instance.enrollPush(_accessToken);

  /// Initiates recovery code enrollment.
  ///
  /// Returns an [EnrollmentChallenge] containing the `recoveryCode`, along with
  /// `id` and `authSession` needed to complete the enrollment via
  /// [confirmEnrollment].
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
      Auth0FlutterWebPlatform.instance.enrollRecoveryCode(_accessToken);

  /// Verifies an enrollment using a one-time password [otp].
  ///
  /// Use this after calling an enrollment method (e.g., [enrollPhone],
  /// [enrollEmail], [enrollTotp]) to confirm the enrollment.
  ///
  /// [factorType] must match the enrolled factor: `"phone"`, `"email"`, or
  /// `"totp"`.
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
    required String id,
    required String authSession,
    required String otp,
    required String factorType,
  }) =>
      Auth0FlutterWebPlatform.instance
          .verifyOtp(_accessToken, id, authSession, otp, factorType);

  /// Confirms an enrollment that does not require a one-time password, namely
  /// push notification and recovery code enrollments.
  ///
  /// Use this after calling [enrollPush] or [enrollRecoveryCode]. For factors
  /// that require an OTP (phone, email, TOTP), use [verifyOtp] instead.
  ///
  /// [factorType] must be `"push-notification"` or `"recovery-code"`.
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
    required String id,
    required String authSession,
    required String factorType,
  }) =>
      Auth0FlutterWebPlatform.instance
          .confirmEnrollment(_accessToken, id, authSession, factorType);

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
    required String id,
    String? name,
    PhoneType? preferredAuthenticationMethod,
  }) =>
      Auth0FlutterWebPlatform.instance.updateAuthenticationMethod(
          _accessToken, id, name, preferredAuthenticationMethod);
}
