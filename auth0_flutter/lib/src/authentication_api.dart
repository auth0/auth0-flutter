import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class AuthenticationApi {
  final Account _account;
  final UserAgent _userAgent;

  AuthenticationApi(this._account, this._userAgent);

  Future<Credentials> login({
    required final String usernameOrEmail,
    required final String password,
    required final String connectionOrRealm,
    final String? audience,
    final Set<String> scopes = const {},
    final Map<String, String> parameters = const {},
  }) =>
      Auth0FlutterAuthPlatform.instance.login(createApiRequest(AuthLoginOptions(
        usernameOrEmail: usernameOrEmail,
        password: password,
        connectionOrRealm: connectionOrRealm,
        audience: audience,
        scopes: scopes,
        parameters: parameters,
      )));

  Future<UserProfile> userProfile({required final String accessToken}) =>
      Auth0FlutterAuthPlatform.instance.userInfo(
          createApiRequest(AuthUserInfoOptions(accessToken: accessToken)));

  Future<DatabaseUser> signup(
          {required final String email,
          required final String password,
          final String? username,
          required final String connection,
          final Map<String, String> userMetadata = const {}}) =>
      Auth0FlutterAuthPlatform.instance.signup(createApiRequest(
          AuthSignupOptions(
              email: email,
              password: password,
              connection: connection,
              username: username,
              userMetadata: userMetadata)));

  Future<Credentials> renewAccessToken({
    required final String refreshToken,
    final Set<String> scopes = const {},
    final Map<String, String> parameters = const {},
  }) =>
      Auth0FlutterAuthPlatform.instance.renewAccessToken(createApiRequest(
          AuthRenewAccessTokenOptions(
              refreshToken: refreshToken,
              scopes: scopes,
              parameters: parameters)));

  Future<void> resetPassword(
          {required final String email,
          required final String connection,
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterAuthPlatform.instance.resetPassword(createApiRequest(
          AuthResetPasswordOptions(
              email: email, connection: connection, parameters: parameters)));

  ApiRequest<TOptions> createApiRequest<TOptions extends RequestOptions>(
          final TOptions options) =>
      ApiRequest<TOptions>(
          account: _account, options: options, userAgent: _userAgent);
}
