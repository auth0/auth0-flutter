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
  external Promise<void> loginWithRedirect(
      [final RedirectLoginOptions options]);
  external Promise<void> handleRedirectCallback([final String? url]);
  external Promise<void> checkSession();
  external Promise<WebCredentials> getTokenSilently(
      [final GetTokenSilentlyOptions options]);
  external Promise<bool> isAuthenticated();
}

typedef Resolver<T> = void Function(T);
typedef Rejecter = void Function(dynamic);

@JS()
class Promise<T> extends Thenable<T> {
  external Promise(
      final void Function(Resolver<T> resolve, Rejecter reject) callback);
  external static Promise<T> resolve<T>(final T value);
  external static Promise<T> reject<T>(final dynamic error);
}

@JS()
class Thenable<T> {
  external Thenable<T> then(final Resolver<T> resolve, [final Rejecter reject]);
}
