import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'method_channel_auth0_flutter.dart';

abstract class Auth0FlutterPlatform extends PlatformInterface {
  Auth0FlutterPlatform() : super(token: _token);

  static Auth0FlutterPlatform get instance => _instance;

  static final Object _token = Object();

  static Auth0FlutterPlatform _instance = MethodChannelAuth0Flutter();

  static set instance(final Auth0FlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> login() {
    throw UnimplementedError('authorize() has not been implemented');
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('authorize() has not been implemented');
  }
}
