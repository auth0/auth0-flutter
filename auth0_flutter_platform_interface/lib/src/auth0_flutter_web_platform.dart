import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class NoOpAuth0FlutterWeb extends Auth0FlutterWebPlatform {}

abstract class Auth0FlutterWebPlatform extends PlatformInterface {
  Auth0FlutterWebPlatform() : super(token: _token);

  static Auth0FlutterWebPlatform get instance => _instance;
  static final Object _token = Object();
  static Auth0FlutterWebPlatform _instance = NoOpAuth0FlutterWeb();
  static set instance(final Auth0FlutterWebPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // methods, e.g. loginWithRedirect()
  // here they should throw an UnimplementedError
}
