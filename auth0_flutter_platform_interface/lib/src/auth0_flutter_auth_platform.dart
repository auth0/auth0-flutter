// coverage:ignore-file
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'auth/auth_login_options.dart';
import 'auth/auth_renew_access_token_options.dart';
import 'auth/auth_reset_password_options.dart';
import 'auth/auth_signup_options.dart';
import 'auth/auth_user_info_options.dart';
import 'credentials.dart';
import 'database_user.dart';
import 'method_channel_auth0_flutter_auth.dart';
import 'user_profile.dart';

abstract class Auth0FlutterAuthPlatform extends PlatformInterface {
  Auth0FlutterAuthPlatform() : super(token: _token);

  static Auth0FlutterAuthPlatform get instance => _instance;

  static final Object _token = Object();

  static Auth0FlutterAuthPlatform _instance = MethodChannelAuth0FlutterAuth();

  static set instance(final Auth0FlutterAuthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Credentials> login(final AuthLoginOptions options) {
    throw UnimplementedError('authLogin() has not been implemented');
  }

  Future<UserProfile> userInfo(final AuthUserInfoOptions options) {
    throw UnimplementedError('authUserInfo() has not been implemented');
  }

  Future<DatabaseUser> signup(final AuthSignupOptions options) {
    throw UnimplementedError('authSignup() has not been implemented');
  }

  Future<Credentials> renewAccessToken(
      final AuthRenewAccessTokenOptions options) {
    throw UnimplementedError('authRenewAccessToken() has not been implemented');
  }

  Future<void> resetPassword(final AuthResetPasswordOptions options) {
    throw UnimplementedError('authResetPassword() has not been implemented');
  }
}
