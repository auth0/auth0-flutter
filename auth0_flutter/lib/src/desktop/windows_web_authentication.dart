import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../../auth0_flutter.dart';

/// A class for authenticating users using the [Auth0 Universal Login page](https://auth0.com/docs/authenticate/login/auth0-universal-login).
///
/// Authentication using Universal Login works by redirecting your user to a
/// login page hosted on Auth0's servers. To achieve this on a desktop device,
/// this class uses the Windows native implementation to perform interactions
/// with Universal Login.
///
/// It is not intended for you to instantiate this class yourself, as an
/// instance of it is already exposed as [Auth0.windowsWebAuthentication].
///
/// Usage examples:
///
/// Basic login:
/// ```dart
/// final auth0 = Auth0('DOMAIN', 'CLIENT_ID');
/// final result = await auth0.windowsWebAuthentication().login(
///   appCustomURL: 'auth0flutter://callback',
/// );
/// final accessToken = result.accessToken;
/// ```
///
/// Login with an HTTPS intermediary server:
/// ```dart
/// final result = await auth0.windowsWebAuthentication().login(
///   appCustomURL: 'auth0flutter://callback',
///   redirectUrl: 'https://your-server.com/callback',
/// );
/// ```
class WindowsWebAuthentication {
  final Account _account;
  final UserAgent _userAgent;

  WindowsWebAuthentication(
    this._account,
    this._userAgent,
  );

  /// Redirects the user to the [Auth0 Universal Login page](https://auth0.com/docs/authenticate/login/auth0-universal-login)
  /// for authentication. If successful, returns a set of tokens as well as the
  /// user's profile (constructed from ID token claims).
  ///
  /// [appCustomURL] is required — the custom-scheme URL (e.g.
  /// `auth0flutter://callback`) that the Windows app listens on for the OAuth
  /// callback.
  ///
  /// When [redirectUrl] is provided, it is used as the `redirect_uri` in the
  /// Auth0 authorization request (e.g. an HTTPS intermediary server). When
  /// omitted, [appCustomURL] is used directly. Both URLs must appear in
  /// **Allowed Callback URLs** in the Auth0 dashboard.
  ///
  /// [Read more about redirecting users](https://auth0.com/docs/authenticate/login/redirect-users-after-login).
  Future<Credentials> login({
    required final String appCustomURL,
    final String? audience,
    final Set<String> scopes = const {
      'openid',
      'profile',
      'email',
      'offline_access'
    },
    final String? redirectUrl,
    final String? organizationId,
    final String? invitationUrl,
    final Map<String, String> parameters = const {},
    final IdTokenValidationConfig idTokenValidationConfig =
        const IdTokenValidationConfig(),
    final Duration authTimeout = const Duration(minutes: 3),
  }) =>
      Auth0FlutterWebAuthPlatform.instance.login(
        WebAuthRequest<WebAuthLoginOptions>(
          account: _account,
          options: WindowsWebAuthLoginOptions(
            appCustomURL: appCustomURL,
            audience: audience,
            scopes: scopes,
            redirectUrl: redirectUrl,
            organizationId: organizationId,
            invitationUrl: invitationUrl,
            parameters: parameters,
            idTokenValidationConfig: idTokenValidationConfig,
            authTimeout: authTimeout,
          ),
          userAgent: _userAgent,
        ),
      );

  /// Redirects the user to the Auth0 logout endpoint to remove their
  /// authentication session.
  ///
  /// [appCustomURL] is required — the custom-scheme URL (e.g.
  /// `auth0flutter://callback`) that the Windows app listens on for the
  /// post-logout redirect from the browser.
  ///
  /// When [returnTo] is provided, it is used as the `returnTo` parameter in
  /// the Auth0 logout request (e.g. an HTTPS intermediary server). When
  /// omitted, [appCustomURL] is used directly. Both URLs must appear in
  /// **Allowed Logout URLs** in the Auth0 dashboard.
  ///
  /// [Read more about redirecting users after logout](https://auth0.com/docs/authenticate/login/logout#redirect-users-after-logout).
  Future<void> logout({
    required final String appCustomURL,
    final String? returnTo,
    final bool federated = false,
  }) =>
      Auth0FlutterWebAuthPlatform.instance.logout(
        WebAuthRequest<WebAuthLogoutOptions>(
          account: _account,
          options: WindowsWebAuthLogoutOptions(
            appCustomURL: appCustomURL,
            returnTo: returnTo,
            federated: federated,
          ),
          userAgent: _userAgent,
        ),
      );
}
