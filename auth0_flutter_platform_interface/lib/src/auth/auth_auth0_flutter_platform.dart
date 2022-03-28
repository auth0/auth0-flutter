import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'auth_code_exchange_result.dart';
import 'auth_login_options.dart';
import 'auth_login_result.dart';
import 'auth_method_channel_auth0_flutter.dart';
import 'auth_renew_access_token_result.dart';
import 'auth_reset_password_options.dart';
import 'auth_sign_up_options.dart';
import 'auth_user_profile_result.dart';

abstract class AuthAuth0FlutterPlatform extends PlatformInterface {
  AuthAuth0FlutterPlatform() : super(token: _token);

  static AuthAuth0FlutterPlatform get instance => _instance;

  static final Object _token = Object();

  static AuthAuth0FlutterPlatform _instance = AuthMethodChannelAuth0Flutter();

  static set instance(final AuthAuth0FlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<AuthLoginResult?> login(final AuthLoginOptions options) {
    throw UnimplementedError('authLogin() has not been implemented');
  }

  Future<AuthCodeExchangeResult?> codeExchange(final String code) {
    throw UnimplementedError('authCodeExchange() has not been implemented');
  }

  Future<AuthUserProfileResult?> userInfo(final String accessToken) {
    throw UnimplementedError('authUserInfo() has not been implemented');
  }

  Future<void> signUp(final AuthSignUpOptions options) {
    throw UnimplementedError('authSignUp() has not been implemented');
  }

  Future<AuthRenewAccessTokenResult?> renewAccessToken(final String refreshToken) {
    throw UnimplementedError('authRenewAccessToken() has not been implemented');
  }

  Future<void> resetPassword(final AuthResetPasswordOptions options) {
    throw UnimplementedError('authResetPassword() has not been implemented');
  }
}
