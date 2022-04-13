import 'package:flutter/services.dart';
import 'auth/api_exception.dart';
import 'auth/auth_login_options.dart';
import 'auth/auth_renew_access_token_options.dart';
import 'auth/auth_reset_password_options.dart';
import 'auth/auth_signup_options.dart';
import 'auth/auth_user_profile_result.dart';
import 'auth0_flutter_auth_platform.dart';
import 'credentials.dart';
import 'database_user.dart';

const MethodChannel _channel = MethodChannel('auth0.com/auth0_flutter/auth');
const String authLoginMethod = 'auth#login';
const String authUserInfoMethod = 'auth#userInfo';
const String authSignUpMethod = 'auth#signUp';
const String authRenewAccessTokenMethod = 'auth#renewAccessToken';
const String authResetPasswordMethod = 'auth#resetPassword';

class MethodChannelAuth0FlutterAuth extends Auth0FlutterAuthPlatform {
  @override
  Future<Credentials> login(final AuthLoginOptions options) async {
    final Map<String, dynamic> result = await invokeMapMethod(
        method: authLoginMethod, options: options.toMap());

    return Credentials.fromMap(result);
  }

  @override
  Future<AuthUserProfileResult?> userInfo(final String accessToken) async {
    await invokeMapMethod(method: authUserInfoMethod);

    return AuthUserProfileResult();
  }

  @override
  Future<DatabaseUser> signup(final AuthSignupOptions options) async {
    final Map<String, dynamic> result = await invokeMapMethod(
        method: authSignUpMethod, options: options.toMap());

    return DatabaseUser.fromMap(result);
  }

  @override
  Future<Credentials> renewAccessToken(
    final AuthRenewAccessTokenOptions options,
  ) async {
    final Map<String, dynamic> result = await invokeMapMethod(
        method: authRenewAccessTokenMethod, options: options.toMap());

    return Credentials.fromMap(result);
  }

  @override
  Future<void> resetPassword(final AuthResetPasswordOptions options) async {
    await invokeMapMethod(method: authResetPasswordMethod, throwOnNull: false);
  }

  Future<Map<String, dynamic>> invokeMapMethod({
    required final String method,
    final Map<String, dynamic>? options,
    final bool? throwOnNull = true,
  }) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(method, options);
    } on PlatformException catch (e) {
      throw ApiException.fromPlatformException(e);
    }

    if (result == null && throwOnNull == true) {
      throw const ApiException.unknown('Channel returned null.');
    }

    return result ?? {};
  }
}
