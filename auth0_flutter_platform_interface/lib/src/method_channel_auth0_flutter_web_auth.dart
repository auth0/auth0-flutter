import 'package:flutter/services.dart';
import 'auth0_flutter_web_auth_platform.dart';
import 'extensions/list_extensions.dart';
import 'web-auth/web_auth_login_options.dart';
import 'web-auth/web_auth_login_result.dart';
import 'web-auth/web_auth_logout_options.dart';

const MethodChannel _channel = MethodChannel('auth0.com/auth0_flutter/web_auth');
const String webAuthLoginMethod = 'webAuth#login';
const String webAuthLogoutMethod = 'webAuth#logout';

class MethodChannelAuth0FlutterWebAuth extends Auth0FlutterWebAuthPlatform {
  @override
  Future<WebAuthLoginResult?> login(final WebAuthLoginOptions options) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMapMethod(webAuthLoginMethod);

    if (result == null) {
      return null;
    }

    final Map<dynamic, dynamic> userProfileMap =
        result['userProfile'] as Map<dynamic, dynamic>;

    return WebAuthLoginResult(
      userProfile: UserProfile(userProfileMap['name'] as String),
      idToken: result['idToken'] as String,
      accessToken: result['accessToken'] as String,
      refreshToken: result['refreshToken'] as String,
      expiresIn: result['expiresIn'] as int,
      scopes: (result['scopes'] as List<Object?>).toTypedSet<String>(),
    );
  }

  @override
  Future<void> logout(final WebAuthLogoutOptions options) async {
    await _channel.invokeMethod(webAuthLogoutMethod) as String;
  }
}
