import 'package:flutter/services.dart';

import 'auth0_flutter_web_auth_platform.dart';
import 'credentials.dart';
import 'request/request.dart';
import 'request/request_options.dart';
import 'web-auth/web_auth_exception.dart';
import 'web-auth/web_auth_login_options.dart';
import 'web-auth/web_auth_logout_options.dart';

const MethodChannel _channel =
    MethodChannel('auth0.com/auth0_flutter/web_auth');
const String loginMethod = 'webAuth#login';
const String logoutMethod = 'webAuth#logout';

class MethodChannelAuth0FlutterWebAuth extends Auth0FlutterWebAuthPlatform {
  @override
  Future<Credentials> login(
      final WebAuthRequest<WebAuthLoginOptions> request) async {
    final Map<String, dynamic> result =
        await invokeRequest(method: loginMethod, request: request);

    return Credentials.fromMap(result);
  }

  @override
  Future<void> logout(
      final WebAuthRequest<WebAuthLogoutOptions> request) async {
    await invokeRequest(
      method: logoutMethod,
      request: request,
      throwOnNull: false,
    );
  }

  Future<Map<String, dynamic>> invokeRequest<TOptions extends RequestOptions>({
    required final String method,
    required final WebAuthRequest<TOptions> request,
    final bool? throwOnNull = true,
  }) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(method, request.toMap());
    } on PlatformException catch (e) {
      throw WebAuthException.fromPlatformException(e);
    }

    if (result == null && throwOnNull == true) {
      throw const WebAuthException.unknown('Channel returned null.');
    }

    return result ?? {};
  }
}
