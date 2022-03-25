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

class MethodChannelAuth0Flutter extends Auth0FlutterPlatform {
  @override
  Future<WebAuthLoginResult?> webAuthLogin(
      final WebAuthLoginOptions options) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod('webAuth#login');

    if (result == null) {
      return null;
    }

    final Map<dynamic, dynamic> userProfileMap = result['userProfile'] as Map<dynamic, dynamic>;

    return WebAuthLoginResult(
      UserProfile(userProfileMap['name'] as String),
      result['idToken'] as String,
      result['accessToken'] as String,
      result['refreshToken'] as String,
      result['expiresIn'] as int,
      (result['scopes'] as List<Object?>).map((final e) => e as String).toSet(),
    );
  }

  @override
  Future<void> webAuthLogout(final WebAuthLogoutOptions options) async {
    await _channel.invokeMethod('webAuth#logout') as String;
  }

  @override
  Future<AuthLoginResult?> authLogin(final AuthLoginOptions options) async {
    final AuthLoginResult? result =
        await _channel.invokeMethod<AuthLoginResult>('webAuth#login');
    return result;
  }

  @override
  Future<AuthCodeExchangeResult?> authCodeExchange(final String code) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod('auth#codeExchange');

    if (result == null) {
      return null;
    }

    return AuthCodeExchangeResult(result['accessToken'] as String);
  }

  @override
  Future<AuthUserProfileResult?> authUserInfo(final String accessToken) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod('auth#userInfo');

    if (result == null) {
      return null;
    }

    return AuthUserProfileResult();
  }

  @override
  Future<void> authSignUp(final AuthSignUpOptions options) async {
    await _channel.invokeMethod('auth#signUp');
  }

  @override
  Future<AuthRenewAccessTokenResult?> authRenewAccessToken(
      final String refreshToken) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod('auth#renewAccessToken');

    if (result == null) {
      return null;
    }

    return AuthRenewAccessTokenResult();
  }

  @override
  Future<void> authResetPassword(final AuthResetPasswordOptions options) async {
    await _channel.invokeMethod('auth#resetPassword');
  }
}
