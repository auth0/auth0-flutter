import 'package:flutter/services.dart';
import 'auth0_flutter_platform.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/auth0_flutter');
    
class MethodChannelAuth0Flutter extends Auth0FlutterPlatform {
  @override
  Future<String> login() async {
    final String result = await _channel.invokeMethod('login');
    return result;
  }

  @override
  Future<String> getPlatformVersion() async {
    final String result = await _channel.invokeMethod('getPlatformVersion');
    return result;
  }
}