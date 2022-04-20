import 'package:flutter/services.dart';

import 'auth/api_exception.dart';
import 'auth/auth_login_options.dart';
import 'auth/auth_renew_access_token_options.dart';
import 'auth/auth_reset_password_options.dart';
import 'auth/auth_signup_options.dart';
import 'auth/auth_user_info_options.dart';
import 'auth0_flutter_auth_platform.dart';
import 'credentials.dart';
import 'database_user.dart';
import 'request/request.dart';
import 'request/request_options.dart';
import 'user_profile.dart';

const MethodChannel _channel = MethodChannel('auth0.com/auth0_flutter/auth');
const String authLoginMethod = 'auth#login';
const String authUserInfoMethod = 'auth#userInfo';
const String authSignUpMethod = 'auth#signUp';
const String authRenewAccessTokenMethod = 'auth#renewAccessToken';
const String authResetPasswordMethod = 'auth#resetPassword';

class MethodChannelAuth0FlutterAuth extends Auth0FlutterAuthPlatform {
  @override
  Future<Credentials> login(final ApiRequest<AuthLoginOptions> request) async {
    final Map<String, dynamic> result =
        await invokeRequest(method: authLoginMethod, request: request);

    return Credentials.fromMap(result);
  }

  @override
  Future<UserProfile> userInfo(final ApiRequest<AuthUserInfoOptions> request) async {

    final Map<String, dynamic> result = await invokeRequest(method: authUserInfoMethod, request: request);

    return UserProfile.fromMap(result);
  }

  @override
  Future<DatabaseUser> signup(final ApiRequest<AuthSignupOptions> request) async {
    final Map<String, dynamic> result =
        await invokeRequest(method: authSignUpMethod, request: request);

    return DatabaseUser.fromMap(result);
  }

  @override
  Future<Credentials> renewAccessToken(
      final ApiRequest<AuthRenewAccessTokenOptions> request) async {
    final Map<String, dynamic> result = await invokeRequest(
      method: authRenewAccessTokenMethod,
      request: request,
    );

    return Credentials.fromMap(result);
  }

  @override
  Future<void> resetPassword(
      final ApiRequest<AuthResetPasswordOptions> request) async {
    await invokeRequest(
      method: authResetPasswordMethod,
      request: request,
      throwOnNull: false,
    );
  }

  Future<Map<String, dynamic>> invokeRequest<TOptions extends RequestOptions>({
    required final String method,
    required final ApiRequest<TOptions> request,
    final bool? throwOnNull = true,
  }) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(method, request.toMap());
    } on PlatformException catch (e) {
      throw ApiException.fromPlatformException(e);
    }

    if (result == null && throwOnNull == true) {
      throw const ApiException.unknown('Channel returned null.');
    }

    return result ?? {};
  }
}
