import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

/// An interface for authenticating users using the [Auth0 Universal Login page](https://auth0.com/docs/authenticate/login/auth0-universal-login).
///
/// Authentication using Universal Login works by redirecting your user to a login page hosted on Auth0's servers. To achieve this on a native device,
/// this class uses the [Auth0.Android](https://github.com/auth0/Auth0.Android) and [Auth0.Swift](https://github.com/auth0/Auth0.swift) SDKs on Android and iOS respectively to
/// perform interactions with Universal Login.
///
/// It is not intended for you to instantiate this class yourself, as an instance of it is already exposed as [Auth0.webAuthentication].
///
/// Usage example:
///
/// ```dart
/// final auth0 = Auth0('DOMAIN', 'CLIENT_ID');
/// final result = await auth0.webAuthentication.login();
/// final accessToken = result.accessToken;
/// ```
class WebAuthentication {
  final Account _account;
  final UserAgent _userAgent;

  WebAuthentication(this._account, this._userAgent);

  /// Redirects the user to the [Auth0 Universal Login page](https://auth0.com/docs/authenticate/login/auth0-universal-login) for authentication. If successful, it returns
  /// a set of tokens, as well as the user's profile (constructed from ID token claims).
  ///
  /// If [redirectUrl] is not specified, a default URL is used that incorporates the `domain` value specified to [Auth0.new], and [scheme] on Android, or the
  /// bundle identifier in iOS. [redirectUrl] must appear in your **Allowed Callback URLs** list for the Auth0 app. [Read more about redirecting users](https://auth0.com/docs/authenticate/login/redirect-users-after-login).
  ///
  /// How the ID token is validated can be configured using [idTokenValidationConfig], but in general the defaults for this are adequate.
  ///
  /// Additonal notes:
  ///
  /// * (iOS only): [useEphemeralSession] controls whether shared persistent storage is used for cookies. [Read more on the effects this setting has](https://github.com/auth0/Auth0.swift/blob/master/FAQ.md#1-how-can-i-disable-the-login-alert-box)
  /// * (Android only): specify [scheme] if you're using a custom URL scheme for your app. This value must match the value used to configure the `auth0Scheme` manifest placeholder, for the Redirect intent filter to work
  /// * [audience] relates to the API Identifier you want to reference in your access tokens (see [API settings](https://auth0.com/docs/get-started/apis/api-settings))
  /// * [scopes] defaults to `openid profile email`. You can override these scopes, but `openid` is always requested regardless of this setting.
  /// * Arbitrary [parameters] can be specified and then picked up in a custom Auth0 [Action](https://auth0.com/docs/customize/actions) or
  /// * If you want to log into a specific organization, provide the [organizationId]. Provide [invitationUrl] if a user has been invited to
  ///   join an organization.
  ///  [Rule](https://auth0.com/docs/customize/rules).
  Future<Credentials> login({
    final String? audience,
    final Set<String> scopes = const {},
    final String? redirectUrl,
    final String? organizationId,
    final String? invitationUrl,
    final String? scheme,
    final bool useEphemeralSession = false,
    final Map<String, String> parameters = const {},
    final IdTokenValidationConfig idTokenValidationConfig =
        const IdTokenValidationConfig(),
  }) =>
      Auth0FlutterWebAuthPlatform.instance.login(_createWebAuthRequest(
          WebAuthLoginOptions(
              audience: audience,
              scopes: scopes,
              redirectUrl: redirectUrl,
              organizationId: organizationId,
              invitationUrl: invitationUrl,
              parameters: parameters,
              idTokenValidationConfig: idTokenValidationConfig,
              scheme: scheme,
              useEphemeralSession: useEphemeralSession)));

  /// Redirects the user to the Auth0 Logout endpoint to remove their authentication session, and log out. The user is immediately redirected back to the application
  /// once logout is complete.
  ///
  /// If [returnTo] is not specified, a default URL is used that incorporates the `domain` value specified to [Auth0.new], and [scheme] on Android, or the
  /// bundle identifier in iOS. [returnTo] must appear in your **Allowed Logout URLs** list for the Auth0 app. [Read more about redirecting users after logout](https://auth0.com/docs/authenticate/login/logout#redirect-users-after-logout).
  ///
  /// (Android only): [scheme] must match the scheme that was used to configure the `auth0Scheme` manifest placeholder
  Future<void> logout({final String? returnTo, final String? scheme}) =>
      Auth0FlutterWebAuthPlatform.instance.logout(_createWebAuthRequest(
        WebAuthLogoutOptions(returnTo: returnTo, scheme: scheme),
      ));

  WebAuthRequest<TOptions>
      _createWebAuthRequest<TOptions extends RequestOptions>(
              final TOptions options) =>
          WebAuthRequest<TOptions>(
              account: _account, options: options, userAgent: _userAgent);
}
