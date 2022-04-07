import 'package:flutter/services.dart';
import '../auth0_flutter_platform_interface.dart';

const MethodChannel _channel =
    MethodChannel('auth0.com/auth0_flutter/web_auth');
const String loginMethod = 'webAuth#login';
const String logoutMethod = 'webAuth#logout';

class MethodChannelAuth0FlutterWebAuth extends Auth0FlutterWebAuthPlatform {
  @override
  Future<LoginResult> login(final WebAuthLoginInput input) async {
    final Map<String, dynamic>? result;

    final credentialsManager =
        NativeCredentialsManager(input.account.domain, input.account.clientId);

    try {
      result = await _channel.invokeMapMethod(loginMethod, input.toMap());
    } on PlatformException catch (e) {
      throw WebAuthException.fromPlatformException(e);
    }

    if (result == null) {
      throw const WebAuthException.unknown('Channel returned null.');
    }

    final loginResult = LoginResult.fromMap(Map<String, dynamic>.from(result));

    await credentialsManager.set(loginResult);
    return loginResult;
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
