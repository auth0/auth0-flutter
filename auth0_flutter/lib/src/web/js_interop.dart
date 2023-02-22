// Here go the annotations –from the js package– that allow calling JS code
// See https://pub.dev/packages/js#usage

// ignore_for_file: non_constant_identifier_names

@JS('auth0')
library auth0;

import 'dart:js_util';

import 'package:js/js.dart';

@JS()
@staticInterop
@anonymous
abstract class AuthorizationParams {
  external factory AuthorizationParams(
      {final String? audience, final String? redirect_uri});
}

extension on AuthorizationParams {
  external String? audience;
  external String? redirect_uri;

  // https://github.com/dart-lang/sdk/issues/38445
  // Workaround of setting property names doesn't seem to work. Tried:
  // @JS('redirect_uri')
  // external String? get redirectUri;

  // @JS('redirect_uri')
  // external set redirectUri(final String? redirectUri);
}

/// Rebuilds the input object, omitting values that are null
@JS()
T stripNulls<T extends Object>(final T obj) {
  final keys = objectKeys(obj);
  final output = newObject<Object>();

  for (var i = 0; i < keys.length; i++) {
    final key = keys[i] as String;
    final value = getProperty(obj, key) as dynamic;

    if (value != null) {
      setProperty(output, key, value);
    }
  }

  return output as T;
}

@JS()
Map<String, dynamic> mapAuthorizationParams(
        final AuthorizationParams? params) =>
    {
      ...params?.audience != null ? {'audience': params?.audience} : {}
    };

@JS()
@staticInterop
@anonymous
class RedirectLoginOptions {
  external factory RedirectLoginOptions(
      {final AuthorizationParams authorizationParams, final String fragment});
}

extension on RedirectLoginOptions {
  external AuthorizationParams? authorizationParams;
  external String? fragment;
}

@JS()
@staticInterop
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
