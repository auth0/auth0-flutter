// Here go the annotations –from the js package– that allow calling JS code
// See https://pub.dev/packages/js#usage

@JS('auth0')
library auth0;

import 'package:js/js.dart';

@JS()
@anonymous
class Auth0ClientOptions {
  external String get domain;
  external String get clientId;

  external factory Auth0ClientOptions(
      {final String domain, final String clientId});
}

@JS()
class Auth0Client {
  external Auth0Client(final Auth0ClientOptions options);
  external Future<void> loginWithRedirect();
}
