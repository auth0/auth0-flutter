// coverage:ignore-file
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../auth0_flutter_platform_interface.dart';

abstract class Auth0FlutterWebAuthPlatform extends PlatformInterface {
  Auth0FlutterWebAuthPlatform() : super(token: _token);

  static Auth0FlutterWebAuthPlatform get instance => _instance;

  static final Object _token = Object();

  static Auth0FlutterWebAuthPlatform _instance =
      MethodChannelAuth0FlutterWebAuth();

  static set instance(final Auth0FlutterWebAuthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Credentials> login(final WebAuthRequest<WebAuthLoginOptions> request) {
    throw UnimplementedError('webAuth.login() has not been implemented');
  }

  Future<void> logout(final WebAuthRequest<WebAuthLogoutOptions> request) {
    throw UnimplementedError('webAuth.logout() has not been implemented');
  }
}
