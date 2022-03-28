import 'package:flutter/services.dart';

import 'auth_auth0_flutter_platform.dart';
import 'auth_code_exchange_result.dart';
import 'auth_login_options.dart';
import 'auth_login_result.dart';
import 'auth_renew_access_token_result.dart';
import 'auth_reset_password_options.dart';
import 'auth_sign_up_options.dart';
import 'auth_user_profile_result.dart';

const MethodChannel _channel = MethodChannel('auth0.com/auth0_flutter');
const String authLoginMethod = 'auth#login';
const String authCodeExchangeMethod = 'auth#codeExchange';
const String authUserInfoMethod = 'auth#userInfo';
const String authSignUpMethod = 'auth#signUp';
const String authRenewAccessTokenMethod = 'auth#renewAccessToken';
const String authResetPasswordMethod = 'auth#resetPassword';

extension ObjectListExtensions on List<Object?> {
  Set<T> toTypedSet<T>() => map((final e) => e as T).toSet();
}

class AuthMethodChannelAuth0Flutter extends AuthAuth0FlutterPlatform {
  @override
  Future<AuthLoginResult?> login(final AuthLoginOptions options) async {
    final AuthLoginResult? result =
        await _channel.invokeMethod<AuthLoginResult>(authLoginMethod);
    return result;
  }

  @override
  Future<AuthCodeExchangeResult?> codeExchange(final String code) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod(authCodeExchangeMethod);

    if (result == null) {
      return null;
    }

    return AuthCodeExchangeResult(accessToken: result['accessToken'] as String);
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

    return AuthRenewAccessTokenResult();
  }

  @override
  Future<void> resetPassword(final AuthResetPasswordOptions options) async {
    await _channel.invokeMethod(authResetPasswordMethod);
  }
}
