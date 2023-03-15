import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'js_interop.dart' as interop;

class Auth0FlutterPlugin extends Auth0FlutterWebPlatform {
  // ignore: avoid_unused_constructor_parameters
  Auth0FlutterPlugin({final interop.Auth0Client? client});

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
  Future<Credentials> loginWithPopup(final PopupLoginOptions? options) {
    throw UnsupportedError(
        'loginWithPopup is only supported on the web platform');
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

  @override
  Future<void> logout(final LogoutOptions? options) {
    throw UnsupportedError('logout is only supported on the web platform');
  }
}
