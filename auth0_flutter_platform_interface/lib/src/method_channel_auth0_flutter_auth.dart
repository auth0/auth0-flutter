import 'package:flutter/services.dart';

import '../auth0_flutter_platform_interface.dart';
import 'auth/api_exception.dart';
import 'auth/auth_login_options.dart';
import 'auth/auth_login_with_otp_options.dart';
import 'auth/auth_passwordless_login_options.dart';
import 'auth/auth_multifactor_challenge_options.dart';
import 'auth/auth_renew_access_token_options.dart';
import 'auth/auth_reset_password_options.dart';
import 'auth/auth_signup_options.dart';
import 'auth/auth_user_info_options.dart';
import 'auth/challenge.dart';
import 'auth0_flutter_auth_platform.dart';
import 'credentials.dart';
import 'database_user.dart';
import 'request/request.dart';
import 'request/request_options.dart';
import 'user_profile.dart';

const MethodChannel _channel = MethodChannel('auth0.com/auth0_flutter/auth');
const String authLoginMethod = 'auth#login';
const String authLoginWithOtpMethod = 'auth#loginOtp';
const String authMultifactorChallengeMethod = 'auth#multifactorChallenge';
const String authStartPasswordlessWithEmailMethod =
    'auth#passwordlessWithEmail';
const String authStartPasswordlessWithPhoneNumberMethod =
    'auth#passwordlessWithPhoneNumber';
const String authLoginWithEmailCodeMethod = 'auth#loginWithEmail';
const String authLoginWithSmsCodeMethod = 'auth#loginWithPhoneNumber';
const String authUserInfoMethod = 'auth#userInfo';
const String authSignUpMethod = 'auth#signUp';
const String authRenewMethod = 'auth#renew';
const String authResetPasswordMethod = 'auth#resetPassword';

class MethodChannelAuth0FlutterAuth extends Auth0FlutterAuthPlatform {
  @override
  Future<Credentials> login(final ApiRequest<AuthLoginOptions> request) async {
    final Map<String, dynamic> result =
        await invokeRequest(method: authLoginMethod, request: request);

    return Credentials.fromMap(result);
  }

  @override
  Future<Credentials> loginWithOtp(
      final ApiRequest<AuthLoginWithOtpOptions> request) async {
    final Map<String, dynamic> result =
        await invokeRequest(method: authLoginWithOtpMethod, request: request);

    return Credentials.fromMap(result);
  }

  @override
  Future<Challenge> multifactorChallenge(
      final ApiRequest<AuthMultifactorChallengeOptions> request) async {
    final Map<String, dynamic> result = await invokeRequest(
        method: authMultifactorChallengeMethod, request: request);

    return Challenge.fromMap(result);
  }


  @override
  Future<void> startPasswordlessWithEmail(
      final ApiRequest<AuthPasswordlessLoginOptions> request) async {
     await invokeRequest(method: authStartPasswordlessWithEmailMethod,
         request: request,throwOnNull: false);
  }


  @override
  Future<Credentials> loginWithEmailCode(
      final ApiRequest<AuthLoginWithCodeOptions> request)  async{
      final Map<String,dynamic> result = await invokeRequest(
          method: authLoginWithEmailCodeMethod, request: request);
      return Credentials.fromMap(result);
  }


  @override
  Future<void> startPasswordlessWithPhoneNumber(
      final ApiRequest<AuthPasswordlessLoginOptions> request)  async{
    await invokeRequest(method: authStartPasswordlessWithPhoneNumberMethod,
        request: request,throwOnNull: false);
  }

  @override
  Future<Credentials> loginWithSmsCode(
      final ApiRequest<AuthLoginWithCodeOptions> request) async {
    final Map<String,dynamic> result = await invokeRequest(
        method: authLoginWithSmsCodeMethod, request: request);
    return Credentials.fromMap(result);
  }

  @override
  Future<UserProfile> userInfo(
      final ApiRequest<AuthUserInfoOptions> request) async {
    final Map<String, dynamic> result =
        await invokeRequest(method: authUserInfoMethod, request: request);

    return UserProfile.fromMap(result);
  }

  @override
  Future<DatabaseUser> signup(
      final ApiRequest<AuthSignupOptions> request) async {
    final Map<String, dynamic> result =
        await invokeRequest(method: authSignUpMethod, request: request);

    return DatabaseUser.fromMap(result);
  }

  @override
  Future<Credentials> renew(final ApiRequest<AuthRenewOptions> request) async {
    final Map<String, dynamic> result = await invokeRequest(
      method: authRenewMethod,
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
