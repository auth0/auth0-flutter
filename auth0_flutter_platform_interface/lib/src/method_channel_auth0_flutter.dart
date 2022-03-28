import 'package:flutter/services.dart';
import 'auth/auth_code_exchange_result.dart';
import 'auth/auth_login_options.dart';
import 'auth/auth_login_result.dart';
import 'auth/auth_renew_access_token_result.dart';
import 'auth/auth_reset_password_options.dart';
import 'auth/auth_sign_up_options.dart';
import 'auth/auth_user_profile_result.dart';
import 'auth0_flutter_platform.dart';
import 'web-auth/web_auth_login_options.dart';
import 'web-auth/web_auth_login_result.dart';
import 'web-auth/web_auth_logout_options.dart';

const MethodChannel _channel = MethodChannel('auth0.com/auth0_flutter');

const String webAuthLoginMethod = 'webAuth#login';
const String webAuthLogoutMethod = 'webAuth#logout';
const String authLoginMethod = 'auth#login';
const String authCodeExchangeMethod = 'auth#codeExchange';
const String authUserInfoMethod = 'auth#userInfo';
const String authSignUpMethod = 'auth#signUp';
const String authRenewAccessTokenMethod = 'auth#renewAccessToken';
const String authResetPasswordMethod = 'auth#resetPassword';

extension ObjectListExtensions on List<Object?> {
  Set<T> toTypedSet<T>() => map((final e) => e as T).toSet();
}

class MethodChannelAuth0Flutter extends Auth0FlutterPlatform {
  @override
  Future<WebAuthLoginResult?> webAuthLogin(
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
  Future<void> webAuthLogout(final WebAuthLogoutOptions options) async {
    await _channel.invokeMethod(webAuthLogoutMethod) as String;
  }

  @override
  Future<AuthLoginResult?> authLogin(final AuthLoginOptions options) async {
    final AuthLoginResult? result =
        await _channel.invokeMethod<AuthLoginResult>(authLoginMethod);
    return result;
  }

  @override
  Future<AuthCodeExchangeResult?> authCodeExchange(final String code) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod(authCodeExchangeMethod);

    if (result == null) {
      return null;
    }

    return AuthCodeExchangeResult(accessToken: result['accessToken'] as String);
  }

  @override
  Future<AuthUserProfileResult?> authUserInfo(final String accessToken) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod(authUserInfoMethod);

    if (result == null) {
      return null;
    }

    return AuthUserProfileResult();
  }

  @override
  Future<void> authSignUp(final AuthSignUpOptions options) async {
    await _channel.invokeMethod(authSignUpMethod);
  }

  @override
  Future<AuthRenewAccessTokenResult?> authRenewAccessToken(
      final String refreshToken) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod(authRenewAccessTokenMethod);

    if (result == null) {
      return null;
    }

    return AuthRenewAccessTokenResult();
  }

  @override
  Future<void> authResetPassword(final AuthResetPasswordOptions options) async {
    await _channel.invokeMethod(authResetPasswordMethod);
  }
}
