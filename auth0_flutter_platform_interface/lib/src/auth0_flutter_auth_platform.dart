// coverage:ignore-file
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'auth/auth_login_options.dart';
import 'auth/auth_login_with_otp_options.dart';
import 'auth/auth_multifactor_challenge_options.dart';
import 'auth/auth_passwordless_login_options.dart';
import 'auth/auth_renew_access_token_options.dart';
import 'auth/auth_reset_password_options.dart';
import 'auth/auth_signup_options.dart';
import 'auth/auth_user_info_options.dart';
import 'auth/challenge.dart';
import 'credentials.dart';
import 'database_user.dart';
import 'method_channel_auth0_flutter_auth.dart';
import 'request/request.dart';
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

  Future<Credentials> login(final ApiRequest<AuthLoginOptions> request) {
    throw UnimplementedError('authLogin() has not been implemented');
  }

  Future<Credentials> loginWithOtp(
      final ApiRequest<AuthLoginWithOtpOptions> request) {
    throw UnimplementedError('authLoginWithOtp() has not been implemented');
  }

  Future<Challenge> multifactorChallenge(
      final ApiRequest<AuthMultifactorChallengeOptions> request) {
    throw UnimplementedError('multifactorChallenge() has not been implemented');
  }

  Future<void> passwordlessWithEmail(
      final ApiRequest<AuthPasswordlessLoginOptions> request) {
    throw UnimplementedError("passwordlessWithEmail() has not been implemented");
  }

  Future<Credentials> loginWithEmail(
      final ApiRequest<AuthPasswordlessLoginOptions> request) {
    throw UnimplementedError('loginWithEmail() has not been implemented');
  }

  Future<void> passwordlessWithPhoneNumber(
      final ApiRequest<AuthPasswordlessLoginOptions> request) {
    throw UnimplementedError
      ('passwordlessWithPhoneNumber() has not been implemented');
  }

  Future<Credentials> loginWithPhoneNumber(
      final ApiRequest<AuthPasswordlessLoginOptions> request) {
    throw UnimplementedError('loginWithPhoneNumber() has not been implemented');
  }

  Future<UserProfile> userInfo(final ApiRequest<AuthUserInfoOptions> request) {
    throw UnimplementedError('authUserInfo() has not been implemented');
  }

  Future<DatabaseUser> signup(final ApiRequest<AuthSignupOptions> request) {
    throw UnimplementedError('authSignup() has not been implemented');
  }

  Future<Credentials> renew(final ApiRequest<AuthRenewOptions> request) {
    throw UnimplementedError('authRenewCredentials() has not been implemented');
  }

  Future<void> resetPassword(
      final ApiRequest<AuthResetPasswordOptions> request) {
    throw UnimplementedError('authResetPassword() has not been implemented');
  }
}
