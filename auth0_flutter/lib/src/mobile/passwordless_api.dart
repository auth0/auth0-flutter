import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

/// Interface for the embedded (non-redirect) **Passwordless OTP on database
/// connections** flow.
///
/// Unlike the passwordless methods on `AuthenticationApi` (which target
/// dedicated `email`/`sms` strategy connections), these methods work against a
/// standard Auth0 database connection configured with `email_otp`/`phone_otp`.
///
/// The flow is challenge-response based:
///
/// 1. Request a challenge with an email or phone identifier. Auth0 delivers a
///    one-time code and returns an opaque [PasswordlessChallenge].
/// 2. Exchange the challenge's `authSession` together with the user-entered
///    code for a set of [Credentials] via [loginWithOtp].
///
/// Your Application must have the **Passwordless OTP** Grant Type enabled.
///
/// It is not intended for you to instantiate this class yourself, as an
/// instance of it is already exposed as `Auth0.passwordless`.
///
/// ```dart
/// final auth0 = Auth0('DOMAIN', 'CLIENT_ID');
///
/// final challenge = await auth0.passwordless.challengeWithEmail(
///   email: 'user@example.com',
///   connection: 'my-db-connection',
/// );
///
/// final credentials = await auth0.passwordless.loginWithOtp(
///   authSession: challenge.authSession,
///   otp: '123456',
/// );
/// ```
class Passwordless {
  final Account _account;
  final UserAgent _userAgent;
  final bool _useDPoP;

  Passwordless(this._account, this._userAgent, {final bool useDPoP = false})
      : _useDPoP = useDPoP;

  /// Requests a passwordless OTP challenge for the given [email] against the
  /// database [connection].
  ///
  /// On success Auth0 delivers a one-time code to the email address and returns
  /// a [PasswordlessChallenge]. Pass its `authSession` to [loginWithOtp] along
  /// with the code the user enters.
  ///
  /// The challenge always succeeds for a valid request, regardless of whether
  /// the user exists (user-enumeration prevention). Set [allowSignup] to `true`
  /// to allow signing up a new user; it defaults to `false`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final challenge = await auth0.passwordless.challengeWithEmail(
  ///   email: 'user@example.com',
  ///   connection: 'my-db-connection',
  ///   allowSignup: false,
  /// );
  /// ```
  Future<PasswordlessChallenge> challengeWithEmail({
    required final String email,
    required final String connection,
    final bool allowSignup = false,
  }) =>
      Auth0FlutterAuthPlatform.instance.passwordlessChallengeWithEmail(
          _createApiRequest(AuthPasswordlessChallengeEmailOptions(
        email: email,
        connection: connection,
        allowSignup: allowSignup,
      )));

  /// Requests a passwordless OTP challenge for the given [phoneNumber] against
  /// the database [connection].
  ///
  /// On success Auth0 delivers a one-time code to the phone number and returns
  /// a [PasswordlessChallenge]. Pass its `authSession` to [loginWithOtp] along
  /// with the code the user enters.
  ///
  /// [deliveryMethod] controls how the code is delivered (`text` or `voice`)
  /// and defaults to [DeliveryMethod.text].
  ///
  /// The challenge always succeeds for a valid request, regardless of whether
  /// the user exists (user-enumeration prevention). Set [allowSignup] to `true`
  /// to allow signing up a new user; it defaults to `false`.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final challenge = await auth0.passwordless.challengeWithPhoneNumber(
  ///   phoneNumber: '+15551234567',
  ///   connection: 'my-db-connection',
  ///   deliveryMethod: DeliveryMethod.text,
  ///   allowSignup: false,
  /// );
  /// ```
  Future<PasswordlessChallenge> challengeWithPhoneNumber({
    required final String phoneNumber,
    required final String connection,
    final DeliveryMethod deliveryMethod = DeliveryMethod.text,
    final bool allowSignup = false,
  }) =>
      Auth0FlutterAuthPlatform.instance.passwordlessChallengeWithPhoneNumber(
          _createApiRequest(AuthPasswordlessChallengePhoneOptions(
        phoneNumber: phoneNumber,
        connection: connection,
        deliveryMethod: deliveryMethod,
        allowSignup: allowSignup,
      )));

  /// Exchanges the [authSession] from a [PasswordlessChallenge] and the
  /// user-entered [otp] for a set of [Credentials].
  ///
  /// This is the second step of the passwordless OTP flow, after
  /// [challengeWithEmail] or [challengeWithPhoneNumber].
  ///
  /// If the user has MFA configured, this call fails with an [ApiException] for
  /// which [ApiException.isMultifactorRequired] is `true`; continue the flow
  /// using the existing MFA APIs (`auth0.api.multifactorChallenge` /
  /// `auth0.api.loginWithOtp`).
  ///
  /// * [scopes] defaults to the native SDK default when left empty. `openid` is
  /// always requested regardless of this setting.
  /// * [audience] relates to the API Identifier you want to reference in your
  /// access tokens.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final credentials = await auth0.passwordless.loginWithOtp(
  ///   authSession: challenge.authSession,
  ///   otp: '123456',
  ///   scopes: {'openid', 'profile', 'email'},
  ///   audience: 'https://api.example.com',
  /// );
  /// ```
  Future<Credentials> loginWithOtp({
    required final String authSession,
    required final String otp,
    final Set<String> scopes = const {},
    final String? audience,
  }) =>
      Auth0FlutterAuthPlatform.instance.passwordlessLoginWithOtp(
          _createApiRequest(AuthPasswordlessLoginWithOtpOptions(
        authSession: authSession,
        otp: otp,
        scopes: scopes,
        audience: audience,
      )));

  ApiRequest<TOptions> _createApiRequest<TOptions extends RequestOptions>(
          final TOptions options) =>
      ApiRequest<TOptions>(
        account: _account,
        options: options,
        userAgent: _userAgent,
        useDPoP: _useDPoP,
      );
}
