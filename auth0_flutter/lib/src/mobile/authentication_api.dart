import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

/// An interface for calling some of the endpoints in
/// [Auth0's Authentication API](https://auth0.com/docs/api/authentication).
///
/// This class presents building blocks for doing more fine-grained
/// authentication with Auth0 using Username and Password login. Unlike
/// `WebAuthentication`, these do **not** use [Auth0 Universal Login](https://auth0.com/docs/authenticate/login/auth0-universal-login) (the recommended way of doing authentication),
/// and thus users are not redirected to Auth0 for authentication.
///
/// It is not intended for you to instantiate this class yourself, as an
/// instance of it is already exposed as `Auth0.api`.
///
/// Usage example:
///
/// ```dart
/// final auth0 = Auth0('DOMAIN', 'CLIENT_ID');
///
/// final result = await auth0.api.login({
///   usernameOrEmail: 'my@email.com',
///   password: 'my_password'
///   connectionOrRealm: 'Username-Password-Authentication'
/// })
///
/// final accessToken = result.accessToken;
/// ```
class AuthenticationApi {
  final Account _account;
  final UserAgent _userAgent;

  AuthenticationApi(this._account, this._userAgent);

  /// Authenticates the user using a [usernameOrEmail] and a [password], with
  /// the specified [connectionOrRealm]. If successful, it returns
  /// a set of tokens, as well as the user's profile (constructed from ID token
  /// claims).
  ///
  /// If using the default username and password database connection,
  /// [connectionOrRealm] should be set to `Username-Password-Authentication`.
  ///
  /// ## Endpoint
  /// https://auth0.com/docs/api/authentication#login
  ///
  /// ## Notes
  ///
  /// * [audience] relates to the API Identifier you want to reference in your
  /// access tokens. See [API settings](https://auth0.com/docs/get-started/apis/api-settings)
  /// to learn more.
  /// * [scopes] defaults to `openid profile email offline_access`. You can
  /// override these scopes, but `openid` is always requested regardless of this
  /// setting.
  /// * [parameters] can be used to sent through custom parameters to the
  /// endpoint to be picked up in a Rule or Action.
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final result = await auth0.api.login({
  ///   usernameOrEmail: 'my@email.com',
  ///   password: 'my_password'
  ///   connectionOrRealm: 'Username-Password-Authentication'
  /// });
  /// ```
  Future<Credentials> login({
    required final String usernameOrEmail,
    required final String password,
    required final String connectionOrRealm,
    final String? audience,
    final Set<String> scopes = const {
      'openid',
      'profile',
      'email',
      'offline_access'
    },
    final Map<String, String> parameters = const {},
  }) =>
      Auth0FlutterAuthPlatform.instance
          .login(_createApiRequest(AuthLoginOptions(
        usernameOrEmail: usernameOrEmail,
        password: password,
        connectionOrRealm: connectionOrRealm,
        audience: audience,
        scopes: scopes,
        parameters: parameters,
      )));

  /// Authenticates the user using a [mfaToken] and an [otp], after [login]
  /// returned with an [ApiException] with [ApiException.isMultifactorRequired]
  /// set to `true`.
  /// If successful, it returns a set of tokens, as well as the user's profile
  /// (constructed from ID token claims).
  ///
  ///
  /// ## Endpoint
  /// https://auth0.com/docs/api/authentication#verify-with-one-time-password-otp-
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final result = await auth0.api.loginWithOtp({
  ///   otp: '123456',
  ///   mfaToken: 'received_mfa_token'
  /// });
  /// ```
  Future<Credentials> loginWithOtp({
    required final String otp,
    required final String mfaToken,
  }) =>
      Auth0FlutterAuthPlatform.instance
          .loginWithOtp(_createApiRequest(AuthLoginWithOtpOptions(
        otp: otp,
        mfaToken: mfaToken,
      )));

  /// Requests a challenge for multi-factor authentication (MFA) based on the
  /// challenge types supported by the app and user.
  ///
  /// The `type` is how the user will get the challenge and prove possession.
  /// Excluding this parameter means that your app accepts all supported
  /// challenge types.
  ///
  /// Supported challenge types include:
  /// - `otp`:  for one-time password (OTP).
  /// - `oob`:  for SMS/voice messages or out-of-band (OOB).
  ///
  /// **Important**: If OTP is supported by the user and you don't want to
  /// request a different factor, you can skip the challenge request and call
  /// [loginWithOtp] directly.
  ///
  /// ## Endpoint
  /// https://auth0.com/docs/api/authentication#challenge-request
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final result = await auth0.api.multifactorChallenge({
  ///   mfaToken: 'received_mfa_token',
  ///   types: [ChallengeType.otp, ChallengeType.oob],
  ///   authenticatorId: 'authenticator_id'
  /// });
  /// ```
  Future<Challenge> multifactorChallenge(
          {required final String mfaToken,
          final List<ChallengeType>? types,
          final String? authenticatorId}) =>
      Auth0FlutterAuthPlatform.instance.multifactorChallenge(_createApiRequest(
          AuthMultifactorChallengeOptions(
              mfaToken: mfaToken,
              types: types,
              authenticatorId: authenticatorId)));

  /// Start a passwordless flow with an [Email](https://auth0.com/docs/api/authentication#get-code-or-link).
  ///
  /// Your Application must have the **Passwordless OTP** Grant Type enabled.
  ///
  /// ## Usage example:
  /// ```dart
  /// final result = await auth0.api.startPasswordlessWithEmail({
  ///   email : 'email',
  ///   passwordlessType : 'PasswordlessType'
  ///   });
  /// ```
  ///
  Future<void> startPasswordlessWithEmail(
          {required final String email,
          required final PasswordlessType passwordlessType}) =>
      Auth0FlutterAuthPlatform.instance.passwordlessWithEmail(_createApiRequest(
          AuthPasswordlessLoginOptions(
              email: email, passwordlessType: passwordlessType)));

  /// Log in a user using an email and a verification code received via Email (Part of passwordless login flow).
  /// The default scope used is 'openid profile email'.
  ///
  /// Your Application must have the **Passwordless OTP** Grant Type enabled.
  ///
  /// ## Usage example:
  /// ```dart
  /// final result = await auth0.api.loginWithEmail({
  ///   email: 'email',
  ///   verificationCode: 'code'
  /// });
  ///```
  Future<Credentials> loginWithEmail(
          {required final String email,
          required final String verificationCode,
          final String? connection,
          final String? scope,
          final String? audience}) =>
      Auth0FlutterAuthPlatform.instance.loginWithEmail(_createApiRequest(
          AuthPasswordlessLoginOptions(
              email: email,
              verificationCode: verificationCode,
              connection: connection,
              scope: scope,
              audience: audience)));

  /// Start a passwordless flow with a [SMS](https://auth0.com/docs/api/authentication#get-code-or-link)
  ///
  /// Your Application requires to have the **Passwordless OTP** Grant Type enabled.
  ///
  /// ## Usage example:
  /// ```dart
  /// final result = await auth0.api.startPasswordlessWithPhoneNumber({
  ///   phoneNumber : 'phoneNumber',
  ///   passwordlessType : 'PasswordlessType'
  ///   });
  /// ```
  Future<void> startPasswordlessWithPhoneNumber(
          {required final String phoneNumber,
            required final PasswordlessType passwordlessType}) =>
      Auth0FlutterAuthPlatform.instance.passwordlessWithPhoneNumber(
          _createApiRequest(AuthPasswordlessLoginOptions(
              phoneNumber: phoneNumber,passwordlessType: passwordlessType)));

  /// Log in a user using a phone number and a verification code received via SMS (Part of passwordless login flow).
  /// The default scope used is 'openid profile email'.
  ///
  /// Your Application must have the **Passwordless OTP** Grant Type enabled.
  ///
  /// ## Usage example:
  /// ```dart
  /// final result = await auth0.api.loginWithPhoneNumber({
  ///   phoneNumber: 'phoneNumber',
  ///   verificationCode: 'code'
  /// });
  ///```
  Future<Credentials> loginWithPhoneNumber(
          {required final String phoneNumber,
          required final String verificationCode,
          final String? connection,
          final String? scope,
          final String? audience}) =>
      Auth0FlutterAuthPlatform.instance.loginWithPhoneNumber(_createApiRequest(
          AuthPasswordlessLoginOptions(
              phoneNumber: phoneNumber,
              verificationCode: verificationCode,
              connection: connection,
              scope: scope,
              audience: audience)));

  /// Fetches the user's profile from the /userinfo endpoint. An [accessToken] from a successful authentication call must be supplied.
  ///
  /// ## Endpoint
  /// https://auth0.com/docs/api/authentication#user-profile
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final result = await auth0.api.login({
  ///   usernameOrEmail: 'my@email.com',
  ///   password: 'my_password'
  ///   connectionOrRealm: 'Username-Password-Authentication'
  /// });
  ///
  /// final profile = await auth0.api.userProfile({
  ///   accessToken: result.accessToken
  /// });
  /// ```
  Future<UserProfile> userProfile(
          {required final String accessToken,
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterAuthPlatform.instance.userInfo(_createApiRequest(
          AuthUserInfoOptions(
              accessToken: accessToken, parameters: parameters)));

  /// Registers a new user with the specified [email] address and [password] in
  /// the specified [connection].
  ///
  /// ## Endpoint
  /// https://auth0.com/docs/api/authentication#signup
  ///
  /// ## Notes
  ///
  /// * [username] is only required if the [connection] you specify requires it
  Future<DatabaseUser> signup(
          {required final String email,
          required final String password,
          final String? username,
          required final String connection,
          final Map<String, String> userMetadata = const {},
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterAuthPlatform.instance.signup(_createApiRequest(
          AuthSignupOptions(
              email: email,
              password: password,
              connection: connection,
              username: username,
              userMetadata: userMetadata,
              parameters: parameters)));

  /// Uses a [refreshToken] to get a new access token.
  ///
  /// ## Endpoint
  /// https://auth0.com/docs/api/authentication#refresh-token
  ///
  /// ## Notes
  /// * Refresh tokens can be retrieved by specifying the `offline_access`
  /// scope during authentication.
  /// * [scopes] can be specified if a reduced set of scopes is desired.
  ///
  /// ## Further reading
  /// [Refresh tokens on Auth0 docs](https://auth0.com/docs/secure/tokens/refresh-tokens)
  ///
  /// ## Usage example
  ///
  /// ```dart
  /// final result = await auth0.api.login({
  ///   usernameOrEmail: 'my@email.com',
  ///   password: 'my_password'
  ///   connectionOrRealm: 'Username-Password-Authentication',
  ///   scopes: {'openid', 'profile', 'email', 'phone', 'offline_access'}
  /// });
  ///
  /// if (result.refreshToken != null) {
  ///    await auth0.api.renewCredentials(refreshToken: result.refreshToken!);
  /// }
  /// ```
  Future<Credentials> renewCredentials({
    required final String refreshToken,
    final Set<String> scopes = const {},
    final Map<String, String> parameters = const {},
  }) =>
      Auth0FlutterAuthPlatform.instance.renew(_createApiRequest(
          AuthRenewOptions(
              refreshToken: refreshToken,
              scopes: scopes,
              parameters: parameters)));

  /// Initiates a reset of password of the user with the specific [email]
  /// address in the specific [connection].
  ///
  /// ## Endpoint
  /// https://auth0.com/docs/api/authentication#change-password
  ///
  /// ## Notes
  ///
  /// Calling this endpoint does not reset the user's password in itself, but it
  ///  asks Auth0 to send the user
  /// an email with a link they can use to reset their password on the web.
  ///
  /// Arbitrary [parameters] can be specified and then picked up in a custom
  /// Auth0 [Action](https://auth0.com/docs/customize/actions) or
  ///  [Rule](https://auth0.com/docs/customize/rules).
  Future<void> resetPassword(
          {required final String email,
          required final String connection,
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterAuthPlatform.instance.resetPassword(_createApiRequest(
          AuthResetPasswordOptions(
              email: email, connection: connection, parameters: parameters)));

  ApiRequest<TOptions> _createApiRequest<TOptions extends RequestOptions>(
          final TOptions options) =>
      ApiRequest<TOptions>(
          account: _account, options: options, userAgent: _userAgent);
}
