import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'src/version.dart';

export 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show CacheLocation, CacheMode;

/// Primary interface for interacting with Auth0 on web platforms.
class Auth0Web {
  final Account _account;

  final UserAgent _userAgent =
      UserAgent(name: 'auth0-flutter', version: version);

  /// Creates an instance of the [Auth0Web] client with the provided [domain]
  /// and [clientId] properties.
  ///
  /// [domain] and [clientId] are both values that can be retrieved from the
  /// application in your [Auth0 Dashboard](https://manage.auth0.com).
  Auth0Web(final String domain, final String clientId)
      : _account = Account(domain, clientId);

  /// Initializes the client.
  ///
  /// This should be called during the loading phase of your application. If
  /// the current user already has a session with Auth0, an instance of
  /// [Credentials] will be returned, populated with their user data and tokens.
  ///
  /// Please see the [ClientOptions] type for the full description of the
  /// available arguments to this method.
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
      final bool? useRefreshTokensFallback}) async {
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
            useRefreshTokensFallback: useRefreshTokensFallback),
        _userAgent);

    if (await hasValidCredentials()) {
      return credentials();
    }

    return null;
  }

  /// Redirects the user to [Auth0 Universal Login](https://auth0.com/docs/authenticate/login/auth0-universal-login)
  /// to log into the app.
  ///
  /// Additonal notes:
  ///
  /// * Use [redirectUrl] to tell Auth0 where to redirect back to once the user
  /// has logged in. This URL must be registered in your Auth0 client settings
  /// under **Allowed Callback URLs** - [read more at Auth0 docs](https://auth0.com/docs/authenticate/login/redirect-users-after-login).
  /// * [audience] relates to the API Identifier you want to reference in your access tokens (see [API settings](https://auth0.com/docs/get-started/apis/api-settings)).
  /// * [scopes] defaults to `openid profile email`. You can
  /// override these scopes, but `openid` is always requested regardless of
  /// this setting.
  /// * If you want to log into a specific organization, provide the
  /// [organizationId]. Provide [invitationUrl] if a user has been invited
  /// to join an organization.
  /// * Arbitrary [parameters] can be specified and then picked up in a custom
  /// Auth0 [Action](https://auth0.com/docs/customize/actions) or
  /// [Rule](https://auth0.com/docs/customize/rules).
  Future<void> loginWithRedirect(
          {final String? audience,
          final String? redirectUrl,
          final String? organizationId,
          final String? invitationUrl,
          final int? maxAge,
          final Set<String> scopes = const {},
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterWebPlatform.instance.loginWithRedirect(LoginOptions(
          audience: audience,
          redirectUrl: redirectUrl,
          organizationId: organizationId,
          invitationUrl: invitationUrl,
          scopes: scopes,
          idTokenValidationConfig: IdTokenValidationConfig(maxAge: maxAge),
          parameters: parameters));

  /// Opens a popup with the `/authorize` URL using the parameters provided as
  /// arguments.
  ///
  /// Random and secure state and nonce parameters will be auto-generated. If
  /// the response is successful, results will be valid according to
  /// their expiration times.
  ///
  /// **Note**: This method should be called from an event handler that was
  /// triggered by user interaction, such as a button click. Otherwise the
  /// popup will be blocked in most browsers.
  ///
  /// Additonal notes:
  ///
  /// * [audience] relates to the API Identifier you want to reference in
  /// your access tokens (see [API settings](https://auth0.com/docs/get-started/apis/api-settings)).
  /// * [scopes] defaults to `openid profile email`. You can
  /// override these scopes, but `openid` is always requested regardless of
  /// this setting.
  /// * If you want to log into a specific organization, provide the
  /// [organizationId]. Provide [invitationUrl] if a user has been invited
  /// to join an organization.
  /// * Arbitrary [parameters] can be specified and then picked up in a custom
  /// Auth0 [Action](https://auth0.com/docs/customize/actions) or
  /// [Rule](https://auth0.com/docs/customize/rules).
  ///
  /// ### Using a custom popup
  /// To provide your own popup window, create it using the `window.open()`
  /// HTML API and set [popupWindow] to the result. You may want to do this
  /// if certain browsers (like Safari) block the popup by default; in this
  /// scenario, creating your own and passing it to `loginWithPopup` may fix it.
  ///
  /// ```dart
  /// final popup = window.open('', '', 'width=400,height=800');
  /// final creds = await auth0Web.loginWithPopup(popupWindow: popup);
  /// ```
  ///
  /// **Note:** This requires that `dart:html` be imported into the plugin
  /// package, which may generate [a warning](https://dart-lang.github.io/linter/lints/avoid_web_libraries_in_flutter.html)
  /// 'avoid_web_libraries_in_flutter'.
  Future<Credentials> loginWithPopup(
          {final String? audience,
          final String? organizationId,
          final String? invitationUrl,
          final int? maxAge,
          final Set<String> scopes = const {},
          final dynamic popupWindow,
          final int? timeoutInSeconds,
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterWebPlatform.instance.loginWithPopup(PopupLoginOptions(
          audience: audience,
          organizationId: organizationId,
          invitationUrl: invitationUrl,
          scopes: scopes,
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
  /// * Use [federated] to log the user out of their identity provider
  ///  (e.g. Google) as well as Auth0. Only applicable if the user authenticated
  /// using an identity provider. [Read more about how federated logout works at Auth0](https://auth0.com/docs/logout/guides/logout-idps)
  Future<void> logout({final bool? federated, final String? returnToUrl}) =>
      Auth0FlutterWebPlatform.instance
          .logout(LogoutOptions(federated: federated, returnTo: returnToUrl));

  /// Retrieves the credentials from the cache and refreshes them if they have
  /// already expired, or will expire in `60` seconds or less.
  ///
  /// New credentials will be obtained either by opening an iframe or a refresh
  /// token (if `useRefreshTokens` is `true`).
  /// If iframes are used, an iframe will be opened with the `/authorize` URL
  /// using the parameters provided. Random and secure `state`
  /// and `nonce` parameters will be auto-generated. If the response is
  /// successful, results will be validated according to their expiration times.
  ///
  /// If refresh tokens are used, the token endpoint will be called directly
  /// with the 'refresh_token' grant. If no refresh token is available to make
  /// this call, the SDK will only fall back to open the `/authorize` URL in an
  /// iframe if the `useRefreshTokensFallback` setting has been set to
  /// `true`. By default this setting is `false`.
  ///
  /// This method may use a web worker to perform the token call if the
  /// in-memory cache is used.
  ///
  /// Additional notes:
  ///
  /// * There's no actual redirect when getting a token silently, but, according
  /// to the spec, a `redirect_uri` param is required. Auth0 uses [redirectUrl]
  /// to validate that the current `origin` matches the [redirectUrl] `origin`
  /// when sending the response. It must be whitelisted under **Allowed Web
  /// Origins** in your Auth0 application's settings.
  /// * If an `audience` value is given to this function, the SDK will always
  /// fall back to using an iframe to make the token exchange.
  /// * In all cases, falling back to an iframe requires access to the `auth0`
  /// cookie.
  /// * [timeoutInSeconds] determines the maximum number of seconds to wait
  /// before declaring the background `/authorize` call as failed.
  /// * Use the [scopes] parameter to set the scope to request for the access
  /// token. If `null` is passed, the previous scope will be kept.
  /// * Use the [cacheMode] parameter to set the cache strategy.
  /// * Use the [parameters] parameter to send additional parameters in the
  /// request to refresh expired credentials.
  Future<Credentials> credentials(
          {final CacheMode? cacheMode,
          final int? timeoutInSeconds,
          final String? redirectUrl,
          final String? audience,
          final Set<String> scopes = const {},
          final Map<String, String> parameters = const {}}) =>
      Auth0FlutterWebPlatform.instance.credentials(CredentialsOptions(
          cacheMode: cacheMode,
          timeoutInSeconds: timeoutInSeconds,
          redirectUrl: redirectUrl,
          audience: audience,
          scopes: scopes,
          parameters: parameters));

  /// Checks if there are non-expired credentials stored.
  Future<bool> hasValidCredentials() =>
      Auth0FlutterWebPlatform.instance.hasValidCredentials();
}
