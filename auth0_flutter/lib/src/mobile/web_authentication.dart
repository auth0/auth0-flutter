import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../../auth0_flutter.dart';

/// An interface for authenticating users using the [Auth0 Universal Login page](https://auth0.com/docs/authenticate/login/auth0-universal-login).
///
/// Authentication using Universal Login works by redirecting your user to a
/// login page hosted on Auth0's servers. To achieve this on a native device,
/// this class uses the [Auth0.Android](https://github.com/auth0/Auth0.Android) and [Auth0.Swift](https://github.com/auth0/Auth0.swift) SDKs on Android and iOS/macOS respectively to
/// perform interactions with Universal Login.
///
/// It is not intended for you to instantiate this class yourself, as an
/// instance of it is already exposed as [Auth0.webAuthentication].
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
  final String? _scheme;
  final CredentialsManager? _credentialsManager;

  WebAuthentication(
    this._account,
    this._userAgent,
    this._scheme,
    this._credentialsManager,
  );

  /// Redirects the user to the [Auth0 Universal Login page](https://auth0.com/docs/authenticate/login/auth0-universal-login) for authentication. If successful, it returns
  /// a set of tokens, as well as the user's profile (constructed from ID token
  /// claims).
  ///
  /// If [redirectUrl] is not specified, a default URL is used that incorporates
  ///  the `domain` value specified to [Auth0.new], and scheme on Android, or
  /// the bundle identifier in iOS/macOS. [redirectUrl] must appear in your
  /// **Allowed Callback URLs** list for the Auth0 app.
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
  /// * (iOS only): [safariViewController] causes [`SFSafariViewController`](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller)
  /// to be used when opening the Universal Login page, as an alternative to the
  /// default `ASWebAuthenticationSession`. You will also need to
  /// [configure your iOS app to automatically resume](https://github.com/auth0/auth0-flutter/blob/main/auth0_flutter/FAQ.md#use-sfsafariviewcontroller)
  /// the Web Auth operation after login.
  /// * (iOS/macOS only): [useHTTPS] controls whether to use `https` as the
  /// scheme for the redirect URL on iOS 17.4+ and macOS 14.4+. When set to
  /// `true`, the bundle identifier of the app will be used as a custom scheme
  /// on older versions of iOS and macOS. Requires an Associated Domain
  /// configured with the `webcredentials` service type, set to your Auth0
  /// domain –or custom domain, if you have one.
  /// * (iOS/macOS only): [useEphemeralSession] controls whether shared persistent
  /// storage is used for cookies. [Read more on the effects this setting has](https://github.com/auth0/auth0-flutter/blob/main/auth0_flutter/FAQ.md#2-how-can-i-disable-the-ios-login-alert-box).
  /// * (android only): [allowedBrowsers] Defines an allowlist of browser
  /// packages
  /// When the user's default browser is in the allowlist, it uses the default
  /// browser
  /// When the user's default browser is not in the allowlist, but the user has
  /// another allowed browser installed, the allowed browser is used instead
  /// When the user's default browser is not in the allowlist, and the user has
  /// no other allowed browser installed, an error is returned
  /// * [useDPoP] enables DPoP for enhanced token security.
  /// See README for details. Defaults to `false`.
  Future<Credentials> login({
    final String? audience,
    final Set<String> scopes = const {
      'openid',
      'profile',
      'email',
      'offline_access',
    },
    final String? redirectUrl,
    final String? organizationId,
    final String? invitationUrl,
    final bool useHTTPS = false,
    final List<String> allowedBrowsers = const [],
    final bool useEphemeralSession = false,
    final Map<String, String> parameters = const {},
    final IdTokenValidationConfig idTokenValidationConfig =
        const IdTokenValidationConfig(),
    final SafariViewController? safariViewController,
    final bool useDPoP = false,
  }) async {
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
          useHTTPS: useHTTPS,
          useEphemeralSession: useEphemeralSession,
          safariViewController: safariViewController,
          allowedBrowsers: allowedBrowsers,
          useDPoP: useDPoP,
        ),
      ),
    );

    await _credentialsManager?.storeCredentials(credentials);

    return credentials;
  }

  /// Redirects the user to the Auth0 Logout endpoint to remove their
  /// authentication session, and log out. The user is immediately redirected
  /// back to the application once logout is complete.
  ///
  /// If [returnTo] is not specified, a default URL is used that incorporates
  /// the `domain` value specified to [Auth0.new], and the custom scheme on
  /// Android, or the bundle identifier on iOS/macOS. [returnTo] must appear in your
  /// **Allowed Logout URLs** list for the Auth0 app.
  /// [Read more about redirecting users after logout](https://auth0.com/docs/authenticate/login/logout#redirect-users-after-logout).
  ///
  /// [useHTTPS] (iOS/macOS only) controls whether to use `https` as the scheme
  /// for the return URL on iOS 17.4+ and macOS 14.4+. When set to `true`, the
  /// bundle identifier of the app will be used as a custom scheme on older
  /// versions of iOS and macOS. Requires an Associated Domain configured with
  /// the `webcredentials` service type, set to your Auth0 domain –or custom
  /// domain, if you have one.
  Future<void> logout({
    final String? returnTo,
    final bool useHTTPS = false,
    final bool federated = false,
  }) async {
    await Auth0FlutterWebAuthPlatform.instance.logout(
      _createWebAuthRequest(
        WebAuthLogoutOptions(
          returnTo: returnTo,
          scheme: _scheme,
          useHTTPS: useHTTPS,
          federated: federated,
        ),
      ),
    );
    await _credentialsManager?.clearCredentials();
  }

  /// Terminates the ongoing web-based operation and reports back that it was
  /// cancelled.
  /// ## Note: This is an iOS specific API
  ///
  static void cancel() {
    Auth0FlutterWebAuthPlatform.instance.cancel();
  }

  WebAuthRequest<TOptions> _createWebAuthRequest<
    TOptions extends RequestOptions
  >(final TOptions options) => WebAuthRequest<TOptions>(
    account: _account,
    options: options,
    userAgent: _userAgent,
  );
}
