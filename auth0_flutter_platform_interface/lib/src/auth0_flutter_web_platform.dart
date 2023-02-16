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

  void initialize(final Account account) {
    throw UnimplementedError();
  }

  Future<void> loginWithRedirect() {
    throw UnimplementedError('web.loginWithRedirect has not been implemented');
  }

  // methods, e.g. loginWithRedirect()
  // here they should throw an UnimplementedError
}
