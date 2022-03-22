
import 'dart:async';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class Auth0Flutter {
  static Future<String?> get platformVersion async {
    return Auth0FlutterPlatform.instance.getPlatformVersion();
  }

  static Future<String?> get login async {
    return Auth0FlutterPlatform.instance.login();
  }
}
