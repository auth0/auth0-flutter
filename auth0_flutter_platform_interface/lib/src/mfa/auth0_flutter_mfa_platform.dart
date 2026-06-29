import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../credentials.dart';
import '../request/request.dart';
import 'method_channel_auth0_flutter_mfa.dart';
import 'mfa_authenticator.dart';
import 'mfa_challenge.dart';
import 'mfa_challenge_options.dart';
import 'mfa_enroll_email_options.dart';
import 'mfa_enroll_phone_options.dart';
import 'mfa_enroll_push_options.dart';
import 'mfa_enroll_totp_options.dart';
import 'mfa_enrollment_challenge.dart';
import 'mfa_get_authenticators_options.dart';
import 'mfa_verify_options.dart';

abstract class Auth0FlutterMfaPlatform extends PlatformInterface {
  Auth0FlutterMfaPlatform() : super(token: _token);

  static Auth0FlutterMfaPlatform get instance => _instance;
  static final Object _token = Object();
  static Auth0FlutterMfaPlatform _instance = MethodChannelAuth0FlutterMfa();

  static set instance(final Auth0FlutterMfaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<MfaAuthenticator>> getAuthenticators(
      final ApiRequest<MfaGetAuthenticatorsOptions> request) {
    throw UnimplementedError('getAuthenticators() has not been implemented');
  }

  Future<MfaEnrollmentChallenge> enrollTotp(
      final ApiRequest<MfaEnrollTotpOptions> request) {
    throw UnimplementedError('enrollTotp() has not been implemented');
  }

  Future<MfaEnrollmentChallenge> enrollPhone(
      final ApiRequest<MfaEnrollPhoneOptions> request) {
    throw UnimplementedError('enrollPhone() has not been implemented');
  }

  Future<MfaEnrollmentChallenge> enrollEmail(
      final ApiRequest<MfaEnrollEmailOptions> request) {
    throw UnimplementedError('enrollEmail() has not been implemented');
  }

  Future<MfaEnrollmentChallenge> enrollPush(
      final ApiRequest<MfaEnrollPushOptions> request) {
    throw UnimplementedError('enrollPush() has not been implemented');
  }

  Future<MfaChallenge> challenge(
      final ApiRequest<MfaChallengeOptions> request) {
    throw UnimplementedError('challenge() has not been implemented');
  }

  Future<Credentials> verify(final ApiRequest<MfaVerifyOptions> request) {
    throw UnimplementedError('verify() has not been implemented');
  }
}
