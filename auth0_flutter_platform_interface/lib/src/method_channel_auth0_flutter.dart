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

const String WEBAUTH_LOGIN_METHOD = "webAuth#login"
const String WEBAUTH_LOGOUT_METHOD = "webAuth#logout"
const String AUTH_LOGIN_METHOD = "auth#login"
const String AUTH_CODEEXCHANGE_METHOD = "auth#codeExchange"
const String AUTH_USERINFO_METHOD = "auth#userInfo"
const String AUTH_SIGNUP_METHOD = "auth#signUp"
const String AUTH_RENEWACCESSTOKEN_METHOD = "auth#renewAccessToken"
const String AUTH_RESETPASSWORD_METHOD = "auth#resetPassword"

extension NumberParsing on List<Object?> {
  Set<T> toSet<T>() {
    return this.map((final e) => e as T)
          .toSet();
  }
  // ···
}

class MethodChannelAuth0Flutter extends Auth0FlutterPlatform {
  @override
  Future<WebAuthLoginResult?> webAuthLogin(
      final WebAuthLoginOptions options) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod(WEBAUTH_LOGIN_METHOD);

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
      scopes: (result['scopes'] as List<Object?>)
          .toSet<String>(),
    );
  }

  @override
  Future<void> webAuthLogout(final WebAuthLogoutOptions options) async {
    await _channel.invokeMethod(WEBAUTH_LOGOUT_METHOD) as String;
  }

  @override
  Future<AuthLoginResult?> authLogin(final AuthLoginOptions options) async {
    final AuthLoginResult? result =
        await _channel.invokeMethod<AuthLoginResult>(AUTH_LOGIN_METHOD);
    return result;
  }

  @override
  Future<AuthCodeExchangeResult?> authCodeExchange(final String code) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod(AUTH_CODEEXCHANGE_METHOD);

    if (result == null) {
      return null;
    }

    return AuthCodeExchangeResult(accessToken: result['accessToken'] as String);
  }

  @override
  Future<AuthUserProfileResult?> authUserInfo(final String accessToken) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod(AUTH_USERINFO_METHOD);

    if (result == null) {
      return null;
    }

    return AuthUserProfileResult();
  }

  @override
  Future<void> authSignUp(final AuthSignUpOptions options) async {
    await _channel.invokeMethod(AUTH_USERINFO_METHOD);
  }

  @override
  Future<AuthRenewAccessTokenResult?> authRenewAccessToken(
      final String refreshToken) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod(AUTH_RENEWACCESSTOKEN_METHOD);

    if (result == null) {
      return null;
    }

    return AuthRenewAccessTokenResult();
  }

  @override
  Future<void> authResetPassword(final AuthResetPasswordOptions options) async {
    await _channel.invokeMethod(AUTH_RESETPASSWORD_METHOD);
  }
}
