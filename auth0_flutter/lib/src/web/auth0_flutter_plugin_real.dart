import 'dart:html';
import 'dart:js_util';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show Account, Auth0FlutterWebPlatform, Credentials, LoginOptions;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'extensions/credentials_extension.dart';
import 'js_interop.dart';

class Auth0FlutterPlugin extends Auth0FlutterWebPlatform {
  static void registerWith(final Registrar registrar) {
    Auth0FlutterWebPlatform.instance = Auth0FlutterPlugin();
  }

  late Auth0Client client;

  @override
  Future<void> initialize(final Account account,
      {final AuthorizationParams? authorizationParams}) {
    client = Auth0Client(
        Auth0ClientOptions(domain: account.domain, clientId: account.clientId));

    final search = window.location.search;

    if (search?.contains('state=') == true &&
        (search?.contains('code=') == true ||
            search?.contains('error=') == true)) {
      return promiseToFuture<void>(client.handleRedirectCallback());
    }

    return promiseToFuture<void>(client.checkSession());
  }

  @override
  Future<void> loginWithRedirect(final LoginOptions? options) {
    final authParams = _stripNulls(AuthorizationParams(
        audience: options?.audience, redirect_uri: options?.redirectUrl));
    final loginOptions = RedirectLoginOptions(authorizationParams: authParams);

    return promiseToFuture<void>(client.loginWithRedirect(loginOptions));
  }

  @override
  Future<Credentials> credentials() async {
    final options = GetTokenSilentlyOptions(detailedResponse: true);
    final result =
        await promiseToFuture<WebCredentials>(client.getTokenSilently(options));

    return CredentialsExtension.fromWeb(result);
  }

  @override
  Future<bool> hasValidCredentials() =>
      promiseToFuture<bool>(client.isAuthenticated());

  /// Rebuilds the input object, omitting values that are null
  T _stripNulls<T extends Object>(final T obj) {
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
}
