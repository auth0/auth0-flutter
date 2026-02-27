import 'dart:io' show Platform;

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../../auth0_flutter.dart';

/// An interface for authenticating users using the [Auth0 Universal Login page](https://auth0.com/docs/authenticate/login/auth0-universal-login).
///
/// Authentication using Universal Login works by redirecting your user to a
/// login page hosted on Auth0's servers. To achieve this on a desktop device,
/// this class uses the Windows native implementation to perform interactions
/// with Universal Login.
///
/// It is not intended for you to instantiate this class yourself, as an
/// instance of it is already exposed as [Auth0.windowsWebAuthentication].
///
///
/// Usage examples:
///
/// Basic login:
/// ```dart
/// final auth0 = Auth0('DOMAIN', 'CLIENT_ID');
/// final result = await auth0.webAuthentication().login(
///   redirectUrl: 'http://localhost:8080/callback',
/// );
/// final accessToken = result.accessToken;
/// ```
///
/// Login with custom timeout:
/// ```dart
/// final auth0 = Auth0('DOMAIN', 'CLIENT_ID');
/// final result = await auth0.windowsWebAuthentication().login(
///   redirectUrl: 'http://localhost:8080/callback',
///   parameters: {
///     'authTimeoutSeconds': '300',  // 5 minutes for MFA
///   },
/// );
/// ```
class WindowsWebAuthentication {
  final Account _account;
  final UserAgent _userAgent;
  final String? _scheme;
  final CredentialsManager? _credentialsManager;

  WindowsWebAuthentication(
    this._account,
    this._userAgent,
    this._scheme,
    this._credentialsManager,
  );

  /// Redirects the user to the [Auth0 Universal Login page](https://auth0.com/docs/authenticate/login/auth0-universal-login) for authentication. If successful, it returns
  /// a set of tokens, as well as the user's profile (constructed from ID token
  /// claims).
  ///
  /// **IMPORTANT**: [redirectUrl] is required for Windows desktop applications.
  /// It must appear in your **Allowed Callback URLs** list for the Auth0 app.
  /// Common values include:
  /// - `auth0flutter://callback` — the app's built-in custom scheme.
  ///   Auth0 redirects directly to the app; no server is required.
  /// - `https://your-server.com/callback` — an HTTPS endpoint on an
  ///   intermediary server that receives the Auth0 redirect and forwards it
  ///   to the app via the `auth0flutter://callback` scheme.
  ///
  /// Regardless of what [redirectUrl] is registered with Auth0, the Windows
  /// plugin always wakes the app by listening on the `auth0flutter://callback`
  /// custom scheme. When using an intermediary server, the server must
  /// forward the callback to `auth0flutter://callback?code=...&state=...`.
  ///
  /// [Read more about redirecting users](https://auth0.com/docs/authenticate/login/redirect-users-after-login).
  ///
  /// How the ID token is validated can be configured using
  /// [idTokenValidationConfig], but in general the defaults for this are
  /// adequate.
  ///
  /// Additional notes:
  ///
  /// * [audience] relates to the API Identifier you want to reference in your
  /// access tokens. See [API settings](https://auth0.com/docs/get-started/apis/api-settings)
  /// to learn more.
  /// * [scopes] defaults to `openid profile email offline_access`. You can
  /// override these scopes, but `openid` is always requested regardless of this
  /// setting.
  /// * Arbitrary [parameters] can be specified and then picked up in a custom
  /// Auth0 [Action](https://auth0.com/docs/customize/actions) or
  /// [Rule](https://auth0.com/docs/customize/rules).
  /// * If you want to log into a specific organization, provide the
  /// [organizationId]. Provide [invitationUrl] if a user has been invited
  /// to join an organization.
  /// * [useDPoP] enables DPoP for enhanced token security.
  /// See README for details. Defaults to `false`.
  ///
  /// ## Windows-Specific Parameters
  ///
  /// The [parameters] map supports the following Windows-specific key:
  ///
  /// ### authTimeoutSeconds
  /// Configures how long to wait for the authentication callback before timing
  /// out.
  ///
  /// **Why customize this?**
  /// - Increase timeout for users who may take longer to authenticate
  ///   (e.g., first-time users, MFA flows, password reset flows)
  /// - Decrease timeout for faster failure detection in automated testing
  /// - Account for slow network connections or complex authentication flows
  ///
  /// **Example:**
  /// ```dart
  /// await auth0.webAuthentication().login(
  ///   redirectUrl: 'http://localhost:8080/callback',
  ///   parameters: {
  ///     'authTimeoutSeconds': '300',  // 5 minutes for MFA flows
  ///   },
  /// );
  /// ```
  ///
  /// **Default:** `'180'` (3 minutes)
  ///
  /// **Note:** If the timeout is reached, a `USER_CANCELLED` error is returned,
  /// as the user likely closed the browser without completing authentication.
  Future<Credentials> login(
      {final String? audience,
      final Set<String> scopes = const {
        'openid',
        'profile',
        'email',
        'offline_access',
      },
      required final String redirectUrl,
      final String? organizationId,
      final String? invitationUrl,
      // Override authTimeoutSeconds in the map if users need more/less time
      // to authenticate (e.g. '300' for MFA flows, '60' for quick testing).
      final Map<String, String> parameters = const {
        'authTimeoutSeconds': '180'
      },
      final IdTokenValidationConfig idTokenValidationConfig =
          const IdTokenValidationConfig(),
      final bool useDPoP = false}) async {
    final credentials = await Auth0FlutterWebAuthPlatform.instance.login(
      _createWebAuthRequest(
        WebAuthLoginOptions(
          audience: audience,
          scopes: scopes,
          redirectUrl: redirectUrl,
          organizationId: organizationId,
          invitationUrl: invitationUrl,
          parameters: parameters,
          idTokenValidationConfig: idTokenValidationConfig,
          scheme: _scheme,
          useDPoP: useDPoP,
        ),
      ),
    );
    return credentials;
  }

  /// Redirects the user to the Auth0 Logout endpoint to remove their
  /// authentication session, and log out. The user is immediately redirected
  /// back to the application once logout is complete.
  ///
  /// If [returnTo] is not specified, a default URL is used:
  /// 'auth0flutter://callback'.
  /// [returnTo] must appear in your **Allowed Logout URLs** list for the
  /// Auth0 app.
  /// [Read more about redirecting users after logout](https://auth0.com/docs/authenticate/login/logout#redirect-users-after-logout).
  ///
  /// [federated] controls whether to perform federated logout, which also logs
  /// the user out from their identity provider.
  Future<void> logout({
    final String? returnTo,
    final bool federated = false,
  }) async {
    await Auth0FlutterWebAuthPlatform.instance.logout(_createWebAuthRequest(
      WebAuthLogoutOptions(
        returnTo: returnTo,
        scheme: _scheme,
        federated: federated,
      ),
    ));
  }

  /// Terminates the ongoing web-based operation and reports back that it was
  /// cancelled.
  /// ## Note: This is not supported on Windows desktop
  ///
  static void cancel() {
    Auth0FlutterWebAuthPlatform.instance.cancel();
  }

  WebAuthRequest<TOptions>
      _createWebAuthRequest<TOptions extends RequestOptions>(
              final TOptions options) =>
          WebAuthRequest<TOptions>(
            account: _account,
            options: options,
            userAgent: _userAgent,
          );
}
