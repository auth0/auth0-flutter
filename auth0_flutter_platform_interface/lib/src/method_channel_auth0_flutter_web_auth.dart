import 'package:flutter/services.dart';

import 'auth0_flutter_web_auth_platform.dart';
import 'extensions/list_extensions.dart';
import 'extensions/map_extensions.dart';
import 'web-auth/web_auth_login_options.dart';
import 'web-auth/web_auth_exception.dart';
import 'web-auth/web_auth_login_input.dart';
import 'web-auth/web_auth_login_result.dart';
import 'web-auth/web_auth_logout_input.dart';

const MethodChannel _channel =
    MethodChannel('auth0.com/auth0_flutter/web_auth');
const String loginMethod = 'webAuth#login';
const String logoutMethod = 'webAuth#logout';

class MethodChannelAuth0FlutterWebAuth extends Auth0FlutterWebAuthPlatform {
  @override
  Future<LoginResult> login(final WebAuthLoginInput input) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(loginMethod, input.toMap());
    } on PlatformException catch (e) {
      throw WebAuthException.fromPlatformException(e);
    }
    if (result == null) {
      throw const WebAuthException.unknown('Channel returned null.');
    }
    
    return LoginResult.fromMap(Map<String, dynamic>.from(result));
  }

  @override
  Future<void> logout(final WebAuthLogoutInput input) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(logoutMethod, input.toMap());
    } on PlatformException catch (e) {
      throw WebAuthException.fromPlatformException(e);
    }
    if (result == null) return;
  }
}
