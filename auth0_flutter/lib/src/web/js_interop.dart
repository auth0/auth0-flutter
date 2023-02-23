// Here go the annotations –from the js package– that allow calling JS code
// See https://pub.dev/packages/js#usage

// ignore_for_file: non_constant_identifier_names

@JS('auth0')
library auth0;

import 'package:js/js.dart';

@JS()
@anonymous
abstract class AuthorizationParams {
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
class Auth0Client {
  external Auth0Client(final Auth0ClientOptions options);
  external Future<void> loginWithRedirect([final RedirectLoginOptions options]);
  external Future<void> handleRedirectCallback([final String? url]);
  external Future<void> checkSession();
}
