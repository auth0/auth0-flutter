import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import 'src/version.dart';

export 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show WebException, CacheLocation;

/// Primary interface for interacting with Auth0 on web platforms.
class Auth0Web {
  final Account _account;

  final UserAgent _userAgent =
      UserAgent(name: 'auth0-flutter', version: version);

  /// Creates an instance of the [Auth0Web] client with the provided [domain]
  /// and [clientId] properties.
  ///
  /// [domain] and [clientId] are both values that can be retrieved from the
  /// **Settings** page of your [Auth0 application](https://manage.auth0.com/#/applications/).
  Auth0Web(final String domain, final String clientId)
      : _account = Account(domain, clientId);

  /// Initializes the client.
  ///
  /// This should be called during the loading phase of your application. If
  /// the current user already has a session with Auth0, an instance of
  /// [Credentials] will be returned, populated with their user data and tokens.
  ///
  /// Additional notes:
  ///
  /// * You can specify custom [leeway] and [issuer] values to be used for the
  /// validation of the ID token. See the [IdTokenValidationConfig] type to
  /// learn more about these parameters.
  /// * See the [ClientOptions] type for the full description of the remaining
  /// parameters for this method.
  /// * [audience] relates to the API Identifier you want to reference in your
  /// access tokens. See [API settings](https://auth0.com/docs/get-started/apis/api-settings)
  /// to learn more.
  /// * [scopes] defaults to `openid profile email`. You can override these
  /// scopes, but `openid` is always requested regardless of this setting.
  Future<Credentials?> onLoad(
      {final int? authorizeTimeoutInSeconds,
      final CacheLocation? cacheLocation,
      final String? cookieDomain,
      final int? httpTimeoutInSeconds,
      final String? issuer,
      final int? leeway,
      final bool? useLegacySameSiteCookie,
      final int? sessionCheckExpiryInDays,
      final bool? useCookiesForTransactions,
      final bool? useFormData,
      final bool? useRefreshTokens,
      final bool? useRefreshTokensFallback,
      final String? audience,
      final Set<String>? scopes,
      final Map<String, String> parameters = const {}}) async {
    await Auth0FlutterWebPlatform.instance.initialize(
        ClientOptions(
            account: _account,
            authorizeTimeoutInSeconds: authorizeTimeoutInSeconds,
            cacheLocation: cacheLocation,
            cookieDomain: cookieDomain,
            httpTimeoutInSeconds: httpTimeoutInSeconds,
            idTokenValidationConfig:
                IdTokenValidationConfig(issuer: issuer, leeway: leeway),
            useLegacySameSiteCookie: useLegacySameSiteCookie,
            sessionCheckExpiryInDays: sessionCheckExpiryInDays,
            useCookiesForTransactions: useCookiesForTransactions,
            useFormData: useFormData,
            useRefreshTokens: useRefreshTokens,
            useRefreshTokensFallback: useRefreshTokensFallback,
            audience: audience,
            scopes: scopes,
            parameters: parameters),
        _userAgent);

    if (await hasValidCredentials()) {
      return credentials();
    }

    return null;
  }

  /// Redirects the user to [Auth0 Universal Login](https://auth0.com/docs/authenticate/login/auth0-universal-login)
  /// to log into the app.
  ///
  /// Additional notes:
  ///
  /// * Use [redirectUrl] to tell Auth0 where to redirect back to once the user
  /// has logged in. This URL must be registered in your Auth0 application
  /// settings under **Allowed Callback URLs**. See the [Auth0 docs](https://auth0.com/docs/authenticate/login/redirect-users-after-login)
  /// to learn more. **Note:** While this property is optional, you would
  /// normally want to set this explicitly unless you have [configured a default route](https://auth0.com/docs/authenticate/login/auth0-universal-login/configure-default-login-routes).
  /// * [audience] relates to the API Identifier you want to reference in your
  /// access tokens. See [API settings](https://auth0.com/docs/get-started/apis/api-settings)
  /// to learn more.
  /// * [scopes] defaults to `openid profile email`. You can override these
  /// scopes, but `openid` is always requested regardless of this setting.
  /// * If you want to log into a specific organization, provide the
  /// [organizationId]. Provide [invitationUrl] if a user has been invited
  /// to join an organization.
  /// * Arbitrary [parameters] can be specified and then picked up in a custom
  /// Auth0 [Action](https://auth0.com/docs/customize/actions) or
  /// [Rule](https://auth0.com/docs/customize/rules).
  /// * [openUrl] Used to control the redirect and not rely on the SDK to do the
  /// actual redirect. Required *auth0-spa-js* `2.0.1` or later.
  Future<void> loginWithRedirect(
          {final String? audience,
          final String? redirectUrl,
          final String? organizationId,
          final String? invitationUrl,
          final int? maxAge,
          final Set<String>? scopes,
          final Future<void> Function(String url)? openUrl,
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterWebPlatform.instance.loginWithRedirect(LoginOptions(
          audience: audience,
          redirectUrl: redirectUrl,
          organizationId: organizationId,
          invitationUrl: invitationUrl,
          scopes: scopes ?? {},
          openUrl: openUrl,
          idTokenValidationConfig: IdTokenValidationConfig(maxAge: maxAge),
          parameters: parameters));

  /// Opens a popup with the `/authorize` URL using the parameters provided as
  /// parameters.
  ///
  /// Random and secure state and nonce parameters will be auto-generated. If
  /// the response is successful, results will be valid according to
  /// their expiration times.
  ///
  /// **Note**: This method should be called from an event handler that was
  /// triggered by user interaction, such as a button click. Otherwise the
  /// popup will be blocked in most browsers.
  ///
  /// Additional notes:
  ///
  /// * [audience] relates to the API Identifier you want to reference in your
  /// access tokens. See [API settings](https://auth0.com/docs/get-started/apis/api-settings)
  /// to learn more.
  /// * [scopes] defaults to `openid profile email`. You can override these
  /// scopes, but `openid` is always requested regardless of this setting.
  /// * If you want to log into a specific organization, provide the
  /// [organizationId]. Provide [invitationUrl] if a user has been invited
  /// to join an organization.
  /// * Arbitrary [parameters] can be specified and then picked up in a custom
  /// Auth0 [Action](https://auth0.com/docs/customize/actions) or
  /// [Rule](https://auth0.com/docs/customize/rules).
  ///
  /// ### Using a custom popup
  ///
  /// To provide your own popup window, create it using the `window.open()`
  /// HTML API and set [popupWindow] to the result. You may want to do this
  /// if certain browsers (like Safari) block the popup by default; in this
  /// scenario, creating your own and passing it to `loginWithPopup()` may fix
  /// it.
  ///
  /// ```dart
  /// final popup = window.open('', '', 'width=400,height=800');
  /// final credentials = await auth0Web.loginWithPopup(popupWindow: popup);
  /// ```
  ///
  /// **Note:** This requires that `dart:html` be imported into the plugin
  /// package, which may generate [the warning](https://dart-lang.github.io/linter/lints/avoid_web_libraries_in_flutter.html)
  /// 'avoid_web_libraries_in_flutter'.
  Future<Credentials> loginWithPopup(
          {final String? audience,
          final String? organizationId,
          final String? invitationUrl,
          final int? maxAge,
          final Set<String>? scopes,
          final dynamic popupWindow,
          final int? timeoutInSeconds,
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterWebPlatform.instance.loginWithPopup(PopupLoginOptions(
          audience: audience,
          organizationId: organizationId,
          invitationUrl: invitationUrl,
          scopes: scopes ?? {},
          idTokenValidationConfig: IdTokenValidationConfig(maxAge: maxAge),
          popupWindow: popupWindow,
          timeoutInSeconds: timeoutInSeconds,
          parameters: parameters));

  /// Redirects the browser to the Auth0 logout endpoint to end the user's
  /// session.
  ///
  /// * Use [returnToUrl] to tell Auth0 where it should redirect back to once
  /// the user has logged out. This URL must be registered in **Allowed
  /// Logout URLs** in your Auth0 client settings. [Read more about how redirecting after logout works](https://auth0.com/docs/logout/guides/redirect-users-after-logout).
  /// **Note:** If [returnToUrl] is not explicitly set, the server will return
  /// the user to the first Allowed Logout URL defined in the client settings
  /// in the dashboard. [Read more](https://auth0.com/docs/authenticate/login/logout/redirect-users-after-logout).
  /// * Use [federated] to log the user out of their identity provider
  /// (such as Google) as well as Auth0. Only applicable if the user
  /// authenticated using an identity provider. [Read more about how federated logout works at Auth0](https://auth0.com/docs/logout/guides/logout-idps).
  Future<void> logout({
    final bool? federated,
    final String? returnToUrl,
    final Future<void> Function(String url)? openUrl,
  }) =>
      Auth0FlutterWebPlatform.instance.logout(LogoutOptions(
        federated: federated,
        returnTo: returnToUrl,
        openUrl: openUrl,
      ));

  /// Retrieves a set of credentials for the user.
  ///
  /// By default, the credentials will be returned from an internal cache. If
  /// the access token within 60 seconds of its expiry time, a new access token
  /// will be retrieved from Auth0. Either an iframe will be used to fetch
  /// this token, or a refresh token, depending on the `useRefreshTokens`
  /// SDK configuration setting.
  ///
  /// **Note:** using an iframe to request tokens relies on third-party cookie
  /// support in your browser if you are not using a [custom domains]().
  ///
  /// Additional notes:
  /// * [audience] and [scopes] can be used to request an access token for a
  /// different API than what was originally requested at login. This has
  /// no effect when using refresh tokens.
  /// * [cacheMode] allows you to control whether the cache is used to return
  /// tokens or not. Please see [CacheMode] for more details.
  /// * [timeoutInSeconds] is used to control the timeout specifically for
  /// when an iframe is used to request new tokens, and has no effect when
  /// using refresh tokens.
  /// * Arbitrary [parameters] can be specified and then picked up in a custom
  /// Auth0 [Action](https://auth0.com/docs/customize/actions) or
  /// [Rule](https://auth0.com/docs/customize/rules).
  Future<Credentials> credentials(
          {final String? audience,
          final num? timeoutInSeconds,
          final Set<String>? scopes,
          final CacheMode? cacheMode,
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterWebPlatform.instance.credentials(CredentialsOptions(
          audience: audience,
          timeoutInSeconds: timeoutInSeconds,
          scopes: scopes,
          cacheMode: cacheMode,
          parameters: parameters));

  /// Indicates whether a user is currently authenticated.
  Future<bool> hasValidCredentials() =>
      Auth0FlutterWebPlatform.instance.hasValidCredentials();
}
