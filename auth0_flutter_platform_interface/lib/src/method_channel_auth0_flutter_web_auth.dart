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
    final Map<String, dynamic> result =
        await invokeMapMethod(method: loginMethod, options: input.toMap());

    return LoginResult.fromMap(result);
  }

  @override
  Future<void> logout(final WebAuthLogoutInput input) async {
    await invokeMapMethod(
      method: logoutMethod,
      options: input.toMap(),
      throwOnNull: false,
    );
  }

  Future<Map<String, dynamic>> invokeMapMethod(
      {required final String method,
      required final Map<String, dynamic> options,
      final bool? throwOnNull = true}) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(method, options);
    } on PlatformException catch (e) {
      throw WebAuthException.fromPlatformException(e);
    }

    if (result == null && throwOnNull == true) {
      throw const WebAuthException.unknown('Channel returned null.');
    }

    return result ?? {};
  }
}
