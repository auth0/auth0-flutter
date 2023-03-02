// ignore_for_file: non_constant_identifier_names

@JS('auth0')
library auth0;

import 'package:js/js.dart';

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
class Auth0ClientOptions {
  external factory Auth0ClientOptions(
      {final String domain, final String clientId});
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
  external Future<void> loginWithRedirect([final RedirectLoginOptions options]);
  external Future<void> handleRedirectCallback([final String? url]);
  external Future<void> checkSession();
  external Future<WebCredentials> getTokenSilently(
      [final GetTokenSilentlyOptions options]);
  external Future<bool> isAuthenticated();
}
