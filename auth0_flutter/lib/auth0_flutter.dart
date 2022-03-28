import 'dart:async';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
export 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class WebAuthAuth0Flutter {
  static Future<WebAuthLoginResult?> get login async =>
      WebAuthAuth0FlutterPlatform.instance.login(WebAuthLoginOptions(
          audience: 'audience', scopes: {'a'}, redirectUri: 'redirect uri'));
}

class AuthAuth0Flutter {
  static Future<AuthLoginResult?> get login async =>
      AuthAuth0FlutterPlatform.instance.login(AuthLoginOptions(
          usernameOrEmail: '', password: '', connectionOrRealm: ''));
}
