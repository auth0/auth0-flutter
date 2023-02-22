import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class Auth0FlutterPlugin extends Auth0FlutterWebPlatform {
  static void registerWith(final Registrar registrar) {}

  @override
  void initialize(final Account account) {
    throw UnsupportedError('initialize is only supported on the web platform');
  }

  // methods, e.g. loginWithRedirect()
  // here they should throw an UnsupportedError
  @override
  Future<void> loginWithRedirect(final LoginOptions? options) {
    throw UnsupportedError(
        'loginWithRedirect is only supported on the web platform');
  }
}
