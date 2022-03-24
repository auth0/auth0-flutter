import 'dart:async';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
export 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class Auth0Flutter {
  static Future<WebAuthLoginResult?> get webAuthLogin async =>
      Auth0FlutterPlatform.instance.webAuthLogin(WebAuthLoginOptions(
          'audience',
          'scopes',
          'redirectUri',
          'ijTokenValidationConfig',
          'organizationId',
          'useEphemeralSession',
          'parameters'));
}
