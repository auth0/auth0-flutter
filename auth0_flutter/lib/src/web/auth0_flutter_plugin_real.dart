import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'js_interop.dart';

class Auth0FlutterPlugin extends Auth0FlutterWebPlatform {
  static void registerWith(final Registrar registrar) {
    Auth0FlutterWebPlatform.instance = Auth0FlutterPlugin();
  }

  late Auth0Client client;

  @override
  void initialize(final Account account) {
    client = Auth0Client(
        Auth0ClientOptions(domain: account.domain, clientId: account.clientId));
  }

  // methods, e.g. loginWithRedirect()
  // here they should call the interop methods, that in turn call the JS methods
  @override
  Future<void> loginWithRedirect() => client.loginWithRedirect();
}
