// ignore_for_file: non_constant_identifier_names

@JS('auth0')
library auth0;

import 'package:js/js.dart';

@JS()
@anonymous
class AuthorizationParams {
  external String? get audience;
  external String? get redirect_uri;

  external factory AuthorizationParams(
      {final String? audience, final String? redirect_uri});
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
