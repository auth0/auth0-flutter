import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class DummyAuth0FlutterWeb extends Auth0FlutterWebPlatform {}

abstract class Auth0FlutterWebPlatform extends PlatformInterface {
  Auth0FlutterWebPlatform() : super(token: _token);

  static Auth0FlutterWebPlatform get instance => _instance;

  static final Object _token = Object();

  static Auth0FlutterWebPlatform _instance = DummyAuth0FlutterWeb();

  static set instance(final Auth0FlutterWebPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void slugify(final String str) {
    throw UnimplementedError(
        'JSAuth0Web.slugify() has not been implemented');
  }
}
