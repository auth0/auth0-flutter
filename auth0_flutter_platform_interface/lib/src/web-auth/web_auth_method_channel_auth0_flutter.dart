import 'package:flutter/services.dart';
import 'web_auth_auth0_flutter_platform.dart';
import 'web_auth_login_options.dart';
import 'web_auth_login_result.dart';
import 'web_auth_logout_options.dart';

const MethodChannel _channel = MethodChannel('auth0.com/auth0_flutter');
const String webAuthLoginMethod = 'webAuth#login';
const String webAuthLogoutMethod = 'webAuth#logout';

extension ObjectListExtensions on List<Object?> {
  Set<T> toTypedSet<T>() => map((final e) => e as T).toSet();
}

class WebAuthMethodChannelAuth0Flutter extends WebAuthAuth0FlutterPlatform {
  @override
  Future<WebAuthLoginResult?> login(
      final WebAuthLoginOptions options) async {
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
