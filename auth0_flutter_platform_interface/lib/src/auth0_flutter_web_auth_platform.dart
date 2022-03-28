import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_auth0_flutter_web_auth.dart';
import 'web-auth/web_auth_login_options.dart';
import 'web-auth/web_auth_login_result.dart';
import 'web-auth/web_auth_logout_options.dart';

abstract class Auth0FlutterWebAuthPlatform extends PlatformInterface {
  Auth0FlutterWebAuthPlatform() : super(token: _token);

  static Auth0FlutterWebAuthPlatform get instance => _instance;

  static final Object _token = Object();

  static Auth0FlutterWebAuthPlatform _instance = MethodChannelAuth0FlutterWebAuth();

  static set instance(final Auth0FlutterWebAuthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<WebAuthLoginResult?> login(final WebAuthLoginOptions options) {
    throw UnimplementedError('webAuth.login() has not been implemented');
  }

  Future<void> logout(final WebAuthLogoutOptions options) {
    throw UnimplementedError('webAuth.logout() has not been implemented');
  }
}
