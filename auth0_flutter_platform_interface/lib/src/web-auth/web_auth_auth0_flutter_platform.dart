import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'web_auth_login_options.dart';
import 'web_auth_login_result.dart';
import 'web_auth_logout_options.dart';
import 'web_auth_method_channel_auth0_flutter.dart';

abstract class WebAuthAuth0FlutterPlatform extends PlatformInterface {
  WebAuthAuth0FlutterPlatform() : super(token: _token);

  static WebAuthAuth0FlutterPlatform get instance => _instance;

  static final Object _token = Object();

  static WebAuthAuth0FlutterPlatform _instance = WebAuthMethodChannelAuth0Flutter();

  static set instance(final WebAuthAuth0FlutterPlatform instance) {
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
