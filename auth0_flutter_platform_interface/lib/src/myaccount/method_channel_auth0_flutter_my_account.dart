import 'package:flutter/services.dart';

import '../request/request.dart';
import '../request/request_options.dart';
import 'auth0_flutter_my_account_platform.dart';
import 'authentication_method.dart';
import 'enrollment_challenge.dart';
import 'factor.dart';
import 'my_account_confirm_enrollment_options.dart';
import 'my_account_delete_auth_method_options.dart';
import 'my_account_enroll_email_options.dart';
import 'my_account_enroll_passkey_challenge_options.dart';
import 'my_account_enroll_passkey_options.dart';
import 'my_account_enroll_phone_options.dart';
import 'my_account_enroll_push_options.dart';
import 'my_account_enroll_recovery_code_options.dart';
import 'my_account_enroll_totp_options.dart';
import 'my_account_exception.dart';
import 'my_account_get_auth_method_options.dart';
import 'my_account_get_auth_methods_options.dart';
import 'my_account_get_factors_options.dart';
import 'my_account_passkey_authentication_method.dart';
import 'my_account_passkey_enrollment_challenge.dart';
import 'my_account_update_auth_method_options.dart';
import 'my_account_verify_otp_options.dart';

const MethodChannel _channel =
    MethodChannel('auth0.com/auth0_flutter/my_account');

const String myAccountGetAuthMethodsMethod =
    'myAccount#getAuthenticationMethods';
const String myAccountGetAuthMethodMethod =
    'myAccount#getAuthenticationMethod';
const String myAccountDeleteAuthMethodMethod =
    'myAccount#deleteAuthenticationMethod';
const String myAccountGetFactorsMethod = 'myAccount#getFactors';
const String myAccountEnrollPasskeyChallengeMethod =
    'myAccount#enrollPasskeyChallenge';
const String myAccountEnrollPasskeyMethod = 'myAccount#enrollPasskey';
const String myAccountEnrollPhoneMethod = 'myAccount#enrollPhone';
const String myAccountEnrollEmailMethod = 'myAccount#enrollEmail';
const String myAccountEnrollTotpMethod = 'myAccount#enrollTotp';
const String myAccountEnrollPushMethod = 'myAccount#enrollPush';
const String myAccountEnrollRecoveryCodeMethod = 'myAccount#enrollRecoveryCode';
const String myAccountVerifyOtpMethod = 'myAccount#verifyOtp';
const String myAccountConfirmEnrollmentMethod = 'myAccount#confirmEnrollment';
const String myAccountUpdateAuthMethodMethod =
    'myAccount#updateAuthenticationMethod';

class MethodChannelAuth0FlutterMyAccount
    extends Auth0FlutterMyAccountPlatform {
  @override
  Future<List<AuthenticationMethod>> getAuthenticationMethods(
      final ApiRequest<MyAccountGetAuthMethodsOptions> request) async {
    final List<dynamic> result = await invokeListRequest(
        method: myAccountGetAuthMethodsMethod, request: request);

    return result
        .map((final item) => AuthenticationMethod.fromMap(
            Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<AuthenticationMethod> getAuthenticationMethod(
      final ApiRequest<MyAccountGetAuthMethodOptions> request) async {
    final Map<String, dynamic> result = await invokeMapRequest(
        method: myAccountGetAuthMethodMethod, request: request);

    return AuthenticationMethod.fromMap(result);
  }

  @override
  Future<void> deleteAuthenticationMethod(
      final ApiRequest<MyAccountDeleteAuthMethodOptions> request) async {
    await invokeMapRequest(
        method: myAccountDeleteAuthMethodMethod,
        request: request,
        throwOnNull: false);
  }

  @override
  Future<List<Factor>> getFactors(
      final ApiRequest<MyAccountGetFactorsOptions> request) async {
    final List<dynamic> result = await invokeListRequest(
        method: myAccountGetFactorsMethod, request: request);

    return result
        .map((final item) =>
            Factor.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<PasskeyEnrollmentChallenge> enrollPasskeyChallenge(
      final ApiRequest<MyAccountEnrollPasskeyChallengeOptions> request) async {
    final Map<String, dynamic> result = await invokeMapRequest(
        method: myAccountEnrollPasskeyChallengeMethod, request: request);

    return PasskeyEnrollmentChallenge.fromMap(result);
  }

  @override
  Future<MyAccountPasskeyAuthenticationMethod> enrollPasskey(
      final ApiRequest<MyAccountEnrollPasskeyOptions> request) async {
    final Map<String, dynamic> result = await invokeMapRequest(
        method: myAccountEnrollPasskeyMethod, request: request);

    return MyAccountPasskeyAuthenticationMethod.fromMap(result);
  }

  @override
  Future<EnrollmentChallenge> enrollPhone(
      final ApiRequest<MyAccountEnrollPhoneOptions> request) async {
    final Map<String, dynamic> result = await invokeMapRequest(
        method: myAccountEnrollPhoneMethod, request: request);

    return EnrollmentChallenge.fromMap(result);
  }

  @override
  Future<EnrollmentChallenge> enrollEmail(
      final ApiRequest<MyAccountEnrollEmailOptions> request) async {
    final Map<String, dynamic> result = await invokeMapRequest(
        method: myAccountEnrollEmailMethod, request: request);

    return EnrollmentChallenge.fromMap(result);
  }

  @override
  Future<EnrollmentChallenge> enrollTotp(
      final ApiRequest<MyAccountEnrollTotpOptions> request) async {
    final Map<String, dynamic> result = await invokeMapRequest(
        method: myAccountEnrollTotpMethod, request: request);

    return EnrollmentChallenge.fromMap(result);
  }

  @override
  Future<EnrollmentChallenge> enrollPush(
      final ApiRequest<MyAccountEnrollPushOptions> request) async {
    final Map<String, dynamic> result = await invokeMapRequest(
        method: myAccountEnrollPushMethod, request: request);

    return EnrollmentChallenge.fromMap(result);
  }

  @override
  Future<EnrollmentChallenge> enrollRecoveryCode(
      final ApiRequest<MyAccountEnrollRecoveryCodeOptions> request) async {
    final Map<String, dynamic> result = await invokeMapRequest(
        method: myAccountEnrollRecoveryCodeMethod, request: request);

    return EnrollmentChallenge.fromMap(result);
  }

  @override
  Future<AuthenticationMethod> verifyOtp(
      final ApiRequest<MyAccountVerifyOtpOptions> request) async {
    final Map<String, dynamic> result = await invokeMapRequest(
        method: myAccountVerifyOtpMethod, request: request);

    return AuthenticationMethod.fromMap(result);
  }

  @override
  Future<AuthenticationMethod> confirmEnrollment(
      final ApiRequest<MyAccountConfirmEnrollmentOptions> request) async {
    final Map<String, dynamic> result = await invokeMapRequest(
        method: myAccountConfirmEnrollmentMethod, request: request);

    return AuthenticationMethod.fromMap(result);
  }

  @override
  Future<AuthenticationMethod> updateAuthenticationMethod(
      final ApiRequest<MyAccountUpdateAuthMethodOptions> request) async {
    final Map<String, dynamic> result = await invokeMapRequest(
        method: myAccountUpdateAuthMethodMethod, request: request);

    return AuthenticationMethod.fromMap(result);
  }

  Future<Map<String, dynamic>>
      invokeMapRequest<TOptions extends RequestOptions>({
    required final String method,
    required final ApiRequest<TOptions> request,
    final bool? throwOnNull = true,
  }) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(method, request.toMap());
    } on PlatformException catch (e) {
      throw MyAccountException.fromPlatformException(e);
    }

    if (result == null && throwOnNull == true) {
      throw const MyAccountException.unknown('Channel returned null.');
    }

    return result ?? {};
  }

  Future<List<dynamic>> invokeListRequest<TOptions extends RequestOptions>({
    required final String method,
    required final ApiRequest<TOptions> request,
  }) async {
    final List<dynamic>? result;
    try {
      result = await _channel.invokeListMethod(method, request.toMap());
    } on PlatformException catch (e) {
      throw MyAccountException.fromPlatformException(e);
    }

    if (result == null) {
      throw const MyAccountException.unknown('Channel returned null.');
    }

    return result;
  }
}
