import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'auth0_flutter_platform_interface.dart';

/// An implementation of [Auth0FlutterPlatform] that uses method channels.
class MethodChannelAuth0Flutter extends Auth0FlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('auth0_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
