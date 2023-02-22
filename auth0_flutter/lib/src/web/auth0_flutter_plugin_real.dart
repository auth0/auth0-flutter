import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show LoginOptions, Auth0FlutterWebPlatform, Account;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';

import 'js_interop.dart';

class Auth0FlutterPlugin extends Auth0FlutterWebPlatform {
  static void registerWith(final Registrar registrar) {
    Auth0FlutterWebPlatform.instance = Auth0FlutterPlugin();
  }

  late Auth0Client client;

  @override
  void initialize(final Account account,
      {final AuthorizationParams? authorizationParams}) {
    client = Auth0Client(
        Auth0ClientOptions(domain: account.domain, clientId: account.clientId));
  }

  // methods, e.g. loginWithRedirect()
  // here they should call the interop methods, that in turn call the JS methods
  @override
  Future<void> loginWithRedirect(final LoginOptions? options) =>
      client.loginWithRedirect(RedirectLoginOptions(
          authorizationParams: stripNulls(AuthorizationParams(
              audience: options?.audience,
              redirect_uri: options?.redirectUrl))));
}
