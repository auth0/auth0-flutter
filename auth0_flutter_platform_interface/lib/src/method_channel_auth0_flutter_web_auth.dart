import 'package:flutter/services.dart';

import 'auth0_flutter_web_auth_platform.dart';
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
    final Map<String, dynamic>? result =
        await _channel.invokeMapMethod(loginMethod, input.toMap());

    if (result == null) {
      throw const WebAuthException.unknown('Channel returned null.');
    }
    if (result['result'] != null) {
      final resultMap = result['result'] as Map<dynamic, dynamic>;
      return LoginResult.fromMap(Map<String, dynamic>.from(resultMap));
    }
    if (result['error'] != null) {
      final errorMap = result['error'] as Map<dynamic, dynamic>;
      throw WebAuthException.fromMap(Map<String, String>.from(errorMap));
    }
    throw const WebAuthException.unknown('Channel returned invalid result.');
  }

  @override
  Future<void> logout(final WebAuthLogoutInput input) async {
    final Map<String, dynamic>? result =
        await _channel.invokeMapMethod(logoutMethod, input.toMap());

    if (result == null) {
      throw const WebAuthException.unknown('Channel returned null.');
    }
    if (result['error'] != null) {
      final errorMap = result['error'] as Map<dynamic, dynamic>;
      throw WebAuthException.fromMap(Map<String, String>.from(errorMap));
    }
    if (result['result'] == null) return;

    throw const WebAuthException.unknown('Channel returned invalid result.');
  }
}
