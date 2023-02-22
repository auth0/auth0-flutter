import 'dart:html';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show Account, Auth0FlutterWebPlatform, LoginOptions;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'js_interop.dart';

class Auth0FlutterPlugin extends Auth0FlutterWebPlatform {
  static void registerWith(final Registrar registrar) {
    Auth0FlutterWebPlatform.instance = Auth0FlutterPlugin();
  }

  late Auth0Client client;

  @override
  Future<void> initialize(final Account account,
      {final AuthorizationParams? authorizationParams}) async {
    client = Auth0Client(
        Auth0ClientOptions(domain: account.domain, clientId: account.clientId));

    final search = window.location.search;

    if (search?.contains('state=') == true &&
        (search?.contains('code=') == true ||
            search?.contains('error=') == true)) {
      await client.handleRedirectCallback();
    }
  }

  @override
  Future<void> loginWithRedirect(final LoginOptions? options) =>
      client.loginWithRedirect(RedirectLoginOptions(
          authorizationParams: stripNulls(AuthorizationParams(
              audience: options?.audience,
              redirect_uri: options?.redirectUrl))));
}
