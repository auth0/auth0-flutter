import 'package:flutter/services.dart';
import 'auth0_flutter_platform.dart';

const MethodChannel _channel = MethodChannel('auth0.com/auth0_flutter');

class MethodChannelAuth0Flutter extends Auth0FlutterPlatform {
  @override
  Future<String> login() async {
    final String result = await _channel.invokeMethod('login')
        as String; // Temporary cast. We should use proper types when we implement the methods
    return result;
  }

  @override
  Future<String> getPlatformVersion() async {
    final String result = await _channel.invokeMethod('getPlatformVersion')
        as String; // Temporary cast. We should use proper types when we implement the methods
    return result;
  }
}
