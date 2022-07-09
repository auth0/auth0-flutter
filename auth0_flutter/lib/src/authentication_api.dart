import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

/// An interface for calling some of the endpoints in [Auth0's Authentication API](https://auth0.com/docs/api/authentication).
///
/// This class presents building blocks for doing more fine-grained authentication with Auth0 using Username and Password login. Unlike
/// [WebAuthentication], these do **not** use [Auth0 Universal Login](https://auth0.com/docs/authenticate/login/auth0-universal-login) (the recommended way of doing authentication),
/// and thus users are not redirected to Auth0 for authentication.
///
/// It is not intended for you to instantiate this class yourself, as an instance of it is already exposed as [Auth0.api].
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

  /// Authenticates the user using a [usernameOrEmail] and a [password], with the specified [connectionOrRealm]. If successful, it returns
  /// a set of tokens, as well as the user's profile (constructed from ID token claims).
  ///
  /// If using the default username and password database connection, [connectionOrRealm] should be set to `Username-Password-Authentication`.
  ///
  /// ## Endpoint docs
  /// https://auth0.com/docs/api/authentication#login
  ///
  /// ## Notes
  ///
  /// * [audience] relates to the API Identifier you want to reference in your access tokens (see [API settings](https://auth0.com/docs/get-started/apis/api-settings))
  /// * [scopes] defaults to `openid profile email offline_access`
  /// * [parameters] can be used to sent through custom parameters to the endpoint to be picked up in a Rule or Action.
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
  /// final profile = await auth0.api.userProfile({ accessToken: result.accessToken });
  /// ```
  Future<UserProfile> userProfile(
          {required final String accessToken,
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterAuthPlatform.instance.userInfo(_createApiRequest(
          AuthUserInfoOptions(
              accessToken: accessToken, parameters: parameters)));

  /// Registers a new user with the specified [email] address and [password] in the specified [connection].
  ///
  /// Endpoint
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
  /// * Refresh tokens can be retrieved by specifying the `offline_access` scope during authentication.
  /// * [scopes] can be specified if a reduced set of scopes is desired.
  ///
  /// ## Further reading
  /// [Refresh Tokens on Auth0 docs](https://auth0.com/docs/secure/tokens/refresh-tokens)
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

  /// Initiates a reset of password of the user with the specific [email] address in the specific [connection].
  ///
  /// ## Endpoint
  /// https://auth0.com/docs/api/authentication#change-password
  ///
  /// ## Notes
  ///
  /// Calling this endpoint does not reset the user's password in itself, but it asks Auth0 to send the user
  /// an email with a link they can use to reset their password on the web.
  ///
  /// Arbitrary [parameters] can be specified and then picked up in a custom Auth0 [Action](https://auth0.com/docs/customize/actions) or
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
