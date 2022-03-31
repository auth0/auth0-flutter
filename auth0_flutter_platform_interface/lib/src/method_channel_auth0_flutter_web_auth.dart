import 'package:flutter/services.dart';
import 'auth0_flutter_web_auth_platform.dart';
import 'extensions/list_extensions.dart';
import 'web-auth/web_auth_login_options.dart';
import 'web-auth/web_auth_login_result.dart';
import 'web-auth/web_auth_logout_options.dart';

const MethodChannel _channel =
    MethodChannel('auth0.com/auth0_flutter/web_auth');
const String webAuthLoginMethod = 'webAuth#login';
const String webAuthLogoutMethod = 'webAuth#logout';

class MethodChannelAuth0FlutterWebAuth extends Auth0FlutterWebAuthPlatform {
  @override
  Future<LoginResult> login(final WebAuthLoginOptions options) async {
    final Map<String, dynamic>? result =
        await _channel.invokeMapMethod(webAuthLoginMethod, options.toMap());

    if (result == null) {
      throw Exception('Channel returned null');
    }

    return LoginResult(
      userProfile: Map<String, dynamic>.from(
          result['userProfile'] as Map<dynamic, dynamic>),
      idToken: result['idToken'] as String,
      accessToken: result['accessToken'] as String,
      refreshToken: result['refreshToken'] as String?,
      expiresIn: result['expiresIn'] as double,
      scopes: (result['scopes'] as List<Object?>).toTypedSet<String>(),
    );
  }

  @override
  Future<void> logout(final WebAuthLogoutOptions options) async {
    await _channel.invokeMethod(webAuthLogoutMethod, options.toMap());
  }
}
