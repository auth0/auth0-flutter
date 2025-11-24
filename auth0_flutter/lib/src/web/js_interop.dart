// ignore_for_file: non_constant_identifier_names

@JS('auth0')
library auth0;

import 'dart:js_interop';

@JS()
@anonymous
extension type AuthorizationParams._(JSObject _) implements JSObject {
  external String? get audience;
  external String? get redirect_uri;
  external String? get acr_values;
  external String? get display;
  external String? get login_hint;
  external String? get prompt;
  external String? get screen_hint;
  external String? get id_token_hint;
  external int? get max_age;
  external String? get ui_locales;
  external String? get connection;
  external String? get invitation;
  external String? get organization;
  external String? get scope;

  external factory AuthorizationParams({
    final String? audience,
    final String? redirect_uri,
    final String? acr_values,
    final String? display,
    final String? login_hint,
    final String? prompt,
    final String? screen_hint,
    final String? id_token_hint,
    final int? max_age,
    final String? ui_locales,
    final String? connection,
    final String? invitation,
    final String? organization,
    final String? scope,
  });
}

@JS()
@anonymous
extension type RedirectLoginOptions._(JSObject _) implements JSObject {
  external JSAny? get appState;
  external AuthorizationParams? get authorizationParams;
  external String? get fragment;
  external Future<void> Function(String url)? openUrl;

  external factory RedirectLoginOptions({
    final JSAny? appState,
    final AuthorizationParams authorizationParams,
    final String fragment,
    final Future<void> Function(String url)? openUrl,
  });
}

@JS()
@anonymous
extension type RedirectLoginResult._(JSObject _) implements JSObject {
  external JSAny? get appState;

  external factory RedirectLoginResult({final JSAny? appState});
}

@JS()
@anonymous
extension type Cache._(JSObject _) implements JSObject {
  external JSAny get(final String key);
  external void remove(final String key);
  external void set(final String key, final JSAny entry);
  external JSPromise<JSArray<JSString>> allKeys();
}

@JS()
@anonymous
extension type Auth0ClientInfo._(JSObject _) implements JSObject {
  external JSObject? get env;
  external String get name;
  external String get version;

  external factory Auth0ClientInfo({
    final JSObject env,
    required final String name,
    required final String version,
  });
}

@JS()
@anonymous
extension type Auth0ClientOptions._(JSObject _) implements JSObject {
  external factory Auth0ClientOptions({
    required final Auth0ClientInfo clientInfo,
    required final String domain,
    required final String clientId,
    final int? authorizeTimeoutInSeconds,
    final String? cacheLocation,
    final String? cookieDomain,
    final int? httpTimeoutInSeconds,
    final String? issuer,
    final int? leeway,
    final bool? legacySameSiteCookie,
    final int? sessionCheckExpiryDays,
    final bool? useCookiesForTransactions,
    final bool? useFormData,
    final bool? useRefreshTokens,
    final bool? useRefreshTokensFallback,
    final AuthorizationParams? authorizationParams,
  });
}

@JS()
@anonymous
extension type GetTokenSilentlyAuthParams._(JSObject _) implements JSObject {
  external String? scope;
  external String? audience;

  external factory GetTokenSilentlyAuthParams({final String? audience, final String? scope});
}

@JS()
@anonymous
extension type GetTokenSilentlyOptions._(JSObject _) implements JSObject {
  external GetTokenSilentlyAuthParams? get authorizationParams;
  external String? get cacheMode;
  external JSNumber? get timeoutInSeconds;
  external bool detailedResponse;

  external factory GetTokenSilentlyOptions({
    final GetTokenSilentlyAuthParams? authorizationParams,
    final String? cacheMode,
    final JSNumber? timeoutInSeconds,
    final bool? detailedResponse,
  });
}

@JS()
@anonymous
extension type WebCredentials._(JSObject _) implements JSObject {
  external String get access_token;
  external String get id_token;
  external JSNumber expires_in;
  external String? get refresh_token;
  external String? get scope;

  external factory WebCredentials({
    final String access_token,
    final String id_token,
    final JSNumber expires_in,
    final String? refresh_token,
    final String? scope,
  });
}

@JS()
@anonymous
extension type LogoutParams._(JSObject _) implements JSObject {
  external String? get returnTo;
  external bool? get federated;

  external factory LogoutParams({final String? returnTo, final bool? federated});
}

@JS()
@anonymous
extension type LogoutOptions._(JSObject _) implements JSObject {
  external LogoutParams? get logoutParams;
  external Future<void> Function(String url)? openUrl;

  external factory LogoutOptions({
    final LogoutParams? logoutParams,
    final Future<void> Function(String url)? openUrl,
  });
}

@JS()
@anonymous
extension type PopupLoginOptions._(JSObject _) implements JSObject {
  external AuthorizationParams? get authorizationParams;

  external factory PopupLoginOptions({final AuthorizationParams authorizationParams});
}

@JS()
@anonymous
extension type PopupConfigOptions._(JSObject _) implements JSObject {
  external JSAny? get popup;
  external int? get timeoutInSeconds;

  external factory PopupConfigOptions({final JSAny? popup, final int? timeoutInSeconds});
}

@JS()
extension type Auth0Client._(JSObject _) implements JSObject {
  external Auth0Client(final Auth0ClientOptions options);
  external Future<void> loginWithRedirect([final RedirectLoginOptions options]);
  external Future<void> loginWithPopup([
    final PopupLoginOptions? options,
    final PopupConfigOptions? config,
  ]);
  external Future<void> handleRedirectCallback([final String? url]);
  external Future<void> checkSession();
  external Future<WebCredentials> getTokenSilently([final GetTokenSilentlyOptions? options]);
  external Future<bool> isAuthenticated();
  external Future<void> logout([final LogoutOptions? logoutParams]);
}
