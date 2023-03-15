import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../auth0_flutter_platform_interface.dart';

class StubAuth0FlutterWeb extends Auth0FlutterWebPlatform {}

abstract class Auth0FlutterWebPlatform extends PlatformInterface {
  Auth0FlutterWebPlatform() : super(token: _token);

  static Auth0FlutterWebPlatform get instance => _instance;
  static final Object _token = Object();
  static Auth0FlutterWebPlatform _instance = StubAuth0FlutterWeb();

  static set instance(final Auth0FlutterWebPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize(
      final ClientOptions clientOptions, final UserAgent userAgent) {
    throw UnimplementedError('web.initialize has not been implemented');
  }

  Future<void> loginWithRedirect(final LoginOptions? options) {
    throw UnimplementedError('web.loginWithRedirect has not been implemented');
  }

  Future<Credentials?> loginWithPopup(final PopupLoginOptions? options) {
    throw UnimplementedError('web.loginWithPopup has not been implemented');
  }

  Future<Credentials> credentials() {
    throw UnimplementedError('web.credentials has not been implemented');
  }

  Future<bool> hasValidCredentials() {
    throw UnimplementedError(
        'web.hasValidCredentials has not been implemented');
  }

  Future<void> logout(final LogoutOptions? options) {
    throw UnimplementedError('web.logout has not been implemented');
  }
}
