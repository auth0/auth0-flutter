// ignore_for_file: non_constant_identifier_names

@JS('auth0')
library auth0;

import 'package:js/js.dart';

typedef Resolver<T> = void Function(T);
typedef Rejecter = void Function(dynamic);

@JS()
class Promise<T> extends Thenable<T> {
  external Promise(
      final void Function(Resolver<T> resolve, Rejecter reject) callback);
  external static Promise<T> resolve<T>([final T value]);
  external static Promise<T> reject<T>(final dynamic error);
}

@JS()
class Thenable<T> {
  external Thenable<T> then(final Resolver<T> resolve, [final Rejecter reject]);
}

@JS()
@anonymous
class AuthorizationParams {
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

  external factory AuthorizationParams(
      {final String? audience,
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
      final String? scope});
}

@JS()
@anonymous
class RedirectLoginOptions {
  external AuthorizationParams? get authorizationParams;
  external String? get fragment;

  external factory RedirectLoginOptions(
      {final AuthorizationParams authorizationParams, final String fragment});
}

@JS()
@anonymous
abstract class Cache {
  T get<T>(final String key);
  void remove(final String key);
  void set<T>(final String key, final T entry);
  Future<List<String>> allKeys();
}

@JS()
@anonymous
class Auth0ClientInfo {
  external Map<String, String>? get env;
  external String get name;
  external String get version;

  external factory Auth0ClientInfo(
      {final Map<String, String> env,
      required final String name,
      required final String version});
}

@JS()
@anonymous
class Auth0ClientOptions {
  external factory Auth0ClientOptions(
      {required final Auth0ClientInfo clientInfo,
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
      final bool? useRefreshTokensFallback});
}

@JS()
@anonymous
class GetTokenSilentlyOptions {
  external AuthorizationParams? get authorizationParams;
  external String? get cacheMode;
  external num? get timeoutInSeconds;
  external bool get detailedResponse;

  external factory GetTokenSilentlyOptions(
      {final AuthorizationParams authorizationParams,
      final String cacheMode,
      final num timeoutInSeconds,
      final bool detailedResponse});
}

@JS()
@anonymous
class WebCredentials {
  external String get access_token;
  external String get id_token;
  external num expires_in;
  external String? get refresh_token;
  external String? get scope;

  external factory WebCredentials(
      {final String access_token,
      final String id_token,
      final num expires_in,
      final String? refresh_token,
      final String? scope});
}

@JS()
class Auth0Client {
  external Auth0Client(final Auth0ClientOptions options);
  external Promise<void> loginWithRedirect(
      [final RedirectLoginOptions options]);
  external Promise<void> handleRedirectCallback([final String? url]);
  external Promise<void> checkSession();
  external Promise<WebCredentials> getTokenSilently(
      [final GetTokenSilentlyOptions? options]);
  external Promise<bool> isAuthenticated();
}
