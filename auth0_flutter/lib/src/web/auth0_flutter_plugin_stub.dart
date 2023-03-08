import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'js_interop.dart';

class Auth0FlutterPlugin extends Auth0FlutterWebPlatform {
  Auth0FlutterPlugin({final Auth0Client? client});

  static void registerWith(final Registrar registrar) {}

  @override
  Future<void> initialize(
      final ClientOptions clientOptions, final UserAgent userAgent) {
    throw UnsupportedError('initialize is only supported on the web platform');
  }

  @override
  Future<void> loginWithRedirect(final LoginOptions? options) {
    throw UnsupportedError(
        'loginWithRedirect is only supported on the web platform');
  }

  @override
  Future<Credentials> credentials() {
    throw UnsupportedError('credentials is only supported on the web platform');
  }

  @override
  Future<bool> hasValidCredentials() {
    throw UnsupportedError(
        'hasValidCredentials is only supported on the web platform');
  }
}
