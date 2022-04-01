import 'package:flutter/services.dart';
import 'auth/auth_login_options.dart';
import 'auth/auth_renew_access_token_result.dart';
import 'auth/auth_reset_password_options.dart';
import 'auth/auth_sign_up_options.dart';
import 'auth/auth_user_profile_result.dart';
import 'auth0_flutter_auth_platform.dart';
import 'web-auth/web_auth_login_result.dart';

const MethodChannel _channel = MethodChannel('auth0.com/auth0_flutter/auth');
const String authLoginMethod = 'auth#login';
const String authUserInfoMethod = 'auth#userInfo';
const String authSignUpMethod = 'auth#signUp';
const String authRenewAccessTokenMethod = 'auth#renewAccessToken';
const String authResetPasswordMethod = 'auth#resetPassword';

class MethodChannelAuth0FlutterAuth extends Auth0FlutterAuthPlatform {
  @override
  Future<LoginResult> login(final AuthLoginOptions options) async {
    final result = await _channel.invokeMethod<LoginResult>(authLoginMethod);

    if (result == null) {
      return throw Exception('Auth channel returned null');
    }

    return result;
  }

  @override
  Future<AuthUserProfileResult?> userInfo(final String accessToken) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod(authUserInfoMethod);

    if (result == null) {
      return null;
    }

    return AuthUserProfileResult();
  }

  @override
  Future<void> signUp(final AuthSignUpOptions options) async {
    await _channel.invokeMethod(authSignUpMethod);
  }

  @override
  Future<AuthRenewAccessTokenResult?> renewAccessToken(
      final String refreshToken) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod(authRenewAccessTokenMethod);

    if (result == null) {
      return null;
    }

    return AuthRenewAccessTokenResult(
      idToken: result['idToken'] as String,
      accessToken: result['accessToken'] as String,
      refreshToken: result['refreshToken'] as String?,
      expiresAt: result['expiresAt'] as double,
      scopes: Set<String>.from(result['scopes'] as List<Object?>),
    );
  }

  @override
  Future<void> resetPassword(final AuthResetPasswordOptions options) async {
    await _channel.invokeMethod(authResetPasswordMethod);
  }
}
