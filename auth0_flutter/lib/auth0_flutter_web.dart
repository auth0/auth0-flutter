import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'src/version.dart';

export 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show CacheLocation;

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
  Future<Credentials> onLoad(
      {final int? authorizeTimeoutInSeconds,
      final CacheLocation? cacheLocation,
      final String? cookieDomain,
      final int? httpTimeoutInSeconds,
      final String? issuer,
      final int? leeway,
      final bool? legacySameSiteCookie,
      final int? sessionCheckExpiryDays,
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
            legacySameSiteCookie: legacySameSiteCookie,
            sessionCheckExpiryDays: sessionCheckExpiryDays,
            useCookiesForTransactions: useCookiesForTransactions,
            useFormData: useFormData,
            useRefreshTokens: useRefreshTokens,
            useRefreshTokensFallback: useRefreshTokensFallback),
        _userAgent);
    return credentials();
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
  Future<void> loginWithRedirect(
          {final String? audience,
          final String? redirectUrl,
          final String? organizationId,
          final String? invitationUrl,
          final Set<String>? scopes}) =>
      Auth0FlutterWebPlatform.instance.loginWithRedirect(LoginOptions(
          audience: audience,
          redirectUrl: redirectUrl,
          organizationId: organizationId,
          invitationUrl: invitationUrl,
          scopes: scopes ?? {}));

  Future<Credentials> credentials() =>
      Auth0FlutterWebPlatform.instance.credentials();

  Future<bool> hasValidCredentials() =>
      Auth0FlutterWebPlatform.instance.hasValidCredentials();
}
