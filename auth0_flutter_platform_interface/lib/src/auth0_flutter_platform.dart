import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'auth/auth_code_exchange_result.dart';
import 'auth/auth_login_options.dart';
import 'auth/auth_login_result.dart';
import 'auth/auth_renew_access_token_result.dart';
import 'auth/auth_reset_password_options.dart';
import 'auth/auth_sign_up_options.dart';
import 'auth/auth_user_profile_result.dart';
import 'method_channel_auth0_flutter.dart';
import 'web-auth/web_auth_login_options.dart';
import 'web-auth/web_auth_login_result.dart';
import 'web-auth/web_auth_logout_options.dart';

abstract class Auth0FlutterPlatform extends PlatformInterface {
  Auth0FlutterPlatform() : super(token: _token);

  static Auth0FlutterPlatform get instance => _instance;

  static final Object _token = Object();

  static Auth0FlutterPlatform _instance = MethodChannelAuth0Flutter();

  static set instance(final Auth0FlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<WebAuthLoginResult?> webAuthLogin(final WebAuthLoginOptions options) {
    throw UnimplementedError('webAuthLogin() has not been implemented');
  }

  Future<void> webAuthLogout(final WebAuthLogoutOptions options) {
    throw UnimplementedError('webAuthLogout() has not been implemented');
  }

  Future<AuthLoginResult?> authLogin(final AuthLoginOptions options) {
    throw UnimplementedError('authLogin() has not been implemented');
  }

  Future<AuthCodeExchangeResult?> authCodeExchange(final String code) {
    throw UnimplementedError('authCodeExchange() has not been implemented');
  }

  Future<AuthUserProfileResult?> authUserInfo(final String accessToken) {
    throw UnimplementedError('authUserInfo() has not been implemented');
  }

  Future<void> authSignUp(final AuthSignUpOptions options) {
    throw UnimplementedError('authSignUp() has not been implemented');
  }

  Future<AuthRenewAccessTokenResult?> authRenewAccessToken(final String refreshToken) {
    throw UnimplementedError('authRenewAccessToken() has not been implemented');
  }

  Future<void> authResetPassword(final AuthResetPasswordOptions options) {
    throw UnimplementedError('authResetPassword() has not been implemented');
  }
}
