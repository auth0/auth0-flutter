import '../../auth0_flutter_platform_interface.dart';

/// The options for the underlying SDK on the web platform.
class ClientOptions {
  /// The account to use, including the `domain` and `clientId` values.
  final Account account;

  /// A maximum number of seconds to wait before declaring background calls to
  /// `/authorize` as failed for timeout. Defaults to `60` seconds.
  final int? authorizeTimeoutInSeconds;

  /// The location to use when storing cache data. Valid values are `memory` or
  /// `localstorage`. Defaults to `memory`.
  final CacheLocation? cacheLocation;

  /// The domain the cookie is accessible from.
  ///
  /// If not set, the cookie is scoped to the current domain, including the
  /// subdomain.
  ///
  /// **Note**: setting this incorrectly may cause silent authentication to stop
  /// working on page load.
  ///
  /// To keep a user logged in across multiple subdomains set this to your
  /// top-level domain and prefixed with a `.` (for instance: `.example.com`).
  final String? cookieDomain;

  /// The timeout for HTTP calls using fetch.
  ///
  /// Defaults to `10` seconds.
  final int? httpTimeoutInSeconds;

  /// Whether an additional cookie with no SameSite attribute is set.
  ///
  /// This is used to support legacy browsers that are not compatible with the
  /// latest SameSite changes.
  ///
  /// This will log a warning on modern browsers. You can disable the
  /// warning by setting this to `false`, but be aware that some older
  /// user agents will not work.
  ///
  /// See https://www.chromium.org/updates/same-site/incompatible-clients.
  ///
  /// Defaults to `true`.
  final bool? useLegacySameSiteCookie;

  /// The number of days until the cookie `auth0.is.authenticated` will expire.
  ///
  /// Defaults to `1` day.
  final int? sessionCheckExpiryInDays;

  /// Whether the SDK will use a cookie for transaction storage, instead of
  /// session storage.
  ///
  /// Defaults to `false`.
  ///
  /// A use case for this is if you rely on your users being able to
  /// authenticate using flows that may end up spanning across multiple
  /// tabs (like magic links) or you cannot otherwise rely on session storage
  /// being available.
  final bool? useCookiesForTransactions;

  /// Whether refresh tokens are used to fetch new access tokens from the Auth0
  /// server.
  ///
  /// If `false`, the legacy technique of using a hidden iframe and the
  /// authorization code grant with `prompt=none` is used.
  ///
  /// Defaults to `false`.
  final bool? useRefreshTokens;

  /// Whether `application/x-www-form-urlencoded` content type is used in the
  /// request to the token endpoint.
  ///
  /// If `false`, the request data is sent as JSON with a content type of
  /// `application/json`.
  ///
  /// Defaults to `true`.
  ///
  /// **Note**: Setting this to false may affect you if you use Auth0 Actions
  /// and are sending custom, non-primitive data. If you disable this, please
  /// verify that your Auth0 Actions continue to work as intended.
  final bool? useFormData;

  /// Whether the client falls back to the technique of using a hidden iframe
  /// and the authorization code grant with `prompt=none` when unable to use
  /// refresh tokens.
  ///
  /// If `false`, the iframe fallback is not used and errors relating to a
  /// failed refresh token grant should be handled appropriately.
  ///
  /// Defaults to `false`.
  final bool? useRefreshTokensFallback;

  /// The configuration for validating ID tokens.
  final IdTokenValidationConfig? idTokenValidationConfig;

  /// The default audience to be used for requesting API access.
  final String? audience;

  /// The default scopes to be used on authentication requests.
  ///
  /// This defaults to `openid profile email` if not specified.
  ///
  /// Note: The openid scope is always applied regardless of this setting.
  final Set<String>? scopes;

  /// The default additional parameters to be sent to Auth0.
  final Map<String, String> parameters;

  ClientOptions(
      {required this.account,
      this.authorizeTimeoutInSeconds,
      this.cacheLocation,
      this.cookieDomain,
      this.httpTimeoutInSeconds,
      this.useLegacySameSiteCookie,
      this.sessionCheckExpiryInDays,
      this.useCookiesForTransactions,
      this.useFormData,
      this.useRefreshTokens,
      this.useRefreshTokensFallback,
      this.idTokenValidationConfig,
      this.audience,
      this.scopes,
      this.parameters = const {}});
}
