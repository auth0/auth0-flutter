import 'package:flutter/services.dart';
import 'auth/api_exception.dart';
import 'auth/auth_login_options.dart';
import 'auth/auth_renew_access_token_options.dart';
import 'auth/auth_renew_access_token_result.dart';
import 'auth/auth_reset_password_options.dart';
import 'auth/auth_signup_options.dart';
import 'auth/auth_user_profile_result.dart';
import 'auth0_flutter_auth_platform.dart';
import 'database_user.dart';
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
    final Map<String, dynamic> result =
        await invokeMapMethod(authLoginMethod, options.toMap());

    return LoginResult.fromMap(result);
  }

  @override
  Future<AuthUserProfileResult?> userInfo(final String accessToken) async {
   await invokeMapMethod(authUserInfoMethod);

    return AuthUserProfileResult();
  }

  @override
  Future<DatabaseUser> signup(final AuthSignupOptions options) async {
    final Map<String, dynamic> result =
        await invokeMapMethod(authSignUpMethod, options.toMap());

    return DatabaseUser.fromMap(result);
  }

  @override
  Future<AuthRenewAccessTokenResult> renewAccessToken(
      final AuthRenewAccessTokenOptions options) async {
    final Map<String, dynamic> result =
        await invokeMapMethod(authRenewAccessTokenMethod, options.toMap());

    return AuthRenewAccessTokenResult.fromMap(result);
  }

  @override
  Future<void> resetPassword(final AuthResetPasswordOptions options) async {
    await invokeMapMethod(authResetPasswordMethod);
  }

  Future<Map<String, dynamic>> invokeMapMethod(final String method,
      [final dynamic arguments]) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(method, arguments);
    } on PlatformException catch (e) {
      throw ApiException.fromPlatformException(e);
    }

    if (result == null) {
      throw const ApiException.unknown('Channel returned null.');
    }

    return result;
  }
}
