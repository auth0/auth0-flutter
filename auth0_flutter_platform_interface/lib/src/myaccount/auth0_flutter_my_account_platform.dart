import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../request/request.dart';
import 'authentication_method.dart';
import 'enrollment_challenge.dart';
import 'factor.dart';
import 'method_channel_auth0_flutter_my_account.dart';
import 'my_account_confirm_enrollment_options.dart';
import 'my_account_delete_auth_method_options.dart';
import 'my_account_enroll_email_options.dart';
import 'my_account_enroll_phone_options.dart';
import 'my_account_enroll_push_options.dart';
import 'my_account_enroll_recovery_code_options.dart';
import 'my_account_enroll_totp_options.dart';
import 'my_account_get_auth_method_options.dart';
import 'my_account_get_auth_methods_options.dart';
import 'my_account_get_factors_options.dart';
import 'my_account_update_auth_method_options.dart';
import 'my_account_verify_otp_options.dart';

abstract class Auth0FlutterMyAccountPlatform extends PlatformInterface {
  Auth0FlutterMyAccountPlatform() : super(token: _token);

  static Auth0FlutterMyAccountPlatform get instance => _instance;
  static final Object _token = Object();
  static Auth0FlutterMyAccountPlatform _instance =
      MethodChannelAuth0FlutterMyAccount();

  static set instance(final Auth0FlutterMyAccountPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<AuthenticationMethod>> getAuthenticationMethods(
      final ApiRequest<MyAccountGetAuthMethodsOptions> request) {
    throw UnimplementedError(
        'getAuthenticationMethods() has not been implemented');
  }

  Future<AuthenticationMethod> getAuthenticationMethod(
      final ApiRequest<MyAccountGetAuthMethodOptions> request) {
    throw UnimplementedError(
        'getAuthenticationMethod() has not been implemented');
  }

  Future<void> deleteAuthenticationMethod(
      final ApiRequest<MyAccountDeleteAuthMethodOptions> request) {
    throw UnimplementedError(
        'deleteAuthenticationMethod() has not been implemented');
  }

  Future<List<Factor>> getFactors(
      final ApiRequest<MyAccountGetFactorsOptions> request) {
    throw UnimplementedError('getFactors() has not been implemented');
  }

  Future<EnrollmentChallenge> enrollPhone(
      final ApiRequest<MyAccountEnrollPhoneOptions> request) {
    throw UnimplementedError('enrollPhone() has not been implemented');
  }

  Future<EnrollmentChallenge> enrollEmail(
      final ApiRequest<MyAccountEnrollEmailOptions> request) {
    throw UnimplementedError('enrollEmail() has not been implemented');
  }

  Future<EnrollmentChallenge> enrollTotp(
      final ApiRequest<MyAccountEnrollTotpOptions> request) {
    throw UnimplementedError('enrollTotp() has not been implemented');
  }

  Future<EnrollmentChallenge> enrollPush(
      final ApiRequest<MyAccountEnrollPushOptions> request) {
    throw UnimplementedError('enrollPush() has not been implemented');
  }

  Future<EnrollmentChallenge> enrollRecoveryCode(
      final ApiRequest<MyAccountEnrollRecoveryCodeOptions> request) {
    throw UnimplementedError('enrollRecoveryCode() has not been implemented');
  }

  Future<AuthenticationMethod> verifyOtp(
      final ApiRequest<MyAccountVerifyOtpOptions> request) {
    throw UnimplementedError('verifyOtp() has not been implemented');
  }

  Future<AuthenticationMethod> confirmEnrollment(
      final ApiRequest<MyAccountConfirmEnrollmentOptions> request) {
    throw UnimplementedError('confirmEnrollment() has not been implemented');
  }

  Future<AuthenticationMethod> updateAuthenticationMethod(
      final ApiRequest<MyAccountUpdateAuthMethodOptions> request) {
    throw UnimplementedError(
        'updateAuthenticationMethod() has not been implemented');
  }
}
