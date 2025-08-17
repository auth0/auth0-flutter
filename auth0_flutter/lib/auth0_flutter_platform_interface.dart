import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'auth0_flutter_method_channel.dart';

abstract class Auth0FlutterPlatform extends PlatformInterface {
  /// Constructs a Auth0FlutterPlatform.
  Auth0FlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static Auth0FlutterPlatform _instance = MethodChannelAuth0Flutter();

  /// The default instance of [Auth0FlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelAuth0Flutter].
  static Auth0FlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Auth0FlutterPlatform] when
  /// they register themselves.
  static set instance(Auth0FlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
