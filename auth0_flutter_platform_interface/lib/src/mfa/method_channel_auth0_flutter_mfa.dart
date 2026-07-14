import 'package:flutter/services.dart';

import '../credentials.dart';
import '../request/request.dart';
import '../request/request_options.dart';
import 'auth0_flutter_mfa_platform.dart';
import 'mfa_authenticator.dart';
import 'mfa_challenge.dart';
import 'mfa_challenge_options.dart';
import 'mfa_enroll_email_options.dart';
import 'mfa_enroll_phone_options.dart';
import 'mfa_enroll_push_options.dart';
import 'mfa_enroll_totp_options.dart';
import 'mfa_enrollment_challenge.dart';
import 'mfa_exception.dart';
import 'mfa_get_authenticators_options.dart';
import 'mfa_verify_options.dart';

const MethodChannel _channel = MethodChannel('auth0.com/auth0_flutter/mfa');

const String mfaGetAuthenticatorsMethod = 'mfa#getAuthenticators';
const String mfaEnrollTotpMethod = 'mfa#enrollTotp';
const String mfaEnrollPhoneMethod = 'mfa#enrollPhone';
const String mfaEnrollEmailMethod = 'mfa#enrollEmail';
const String mfaEnrollPushMethod = 'mfa#enrollPush';
const String mfaChallengeMethod = 'mfa#challenge';
const String mfaVerifyMethod = 'mfa#verify';

class MethodChannelAuth0FlutterMfa extends Auth0FlutterMfaPlatform {
  @override
  Future<List<MfaAuthenticator>> getAuthenticators(
      final ApiRequest<MfaGetAuthenticatorsOptions> request) async {
    final List<dynamic> result = await _invokeListRequest(
        method: mfaGetAuthenticatorsMethod, request: request);

    return result
        .map((final item) =>
            MfaAuthenticator.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<MfaEnrollmentChallenge> enrollTotp(
      final ApiRequest<MfaEnrollTotpOptions> request) async {
    final Map<String, dynamic> result =
        await _invokeMapRequest(method: mfaEnrollTotpMethod, request: request);

    return MfaEnrollmentChallenge.fromMap(result);
  }

  @override
  Future<MfaEnrollmentChallenge> enrollPhone(
      final ApiRequest<MfaEnrollPhoneOptions> request) async {
    final Map<String, dynamic> result =
        await _invokeMapRequest(method: mfaEnrollPhoneMethod, request: request);

    return MfaEnrollmentChallenge.fromMap(result);
  }

  @override
  Future<MfaEnrollmentChallenge> enrollEmail(
      final ApiRequest<MfaEnrollEmailOptions> request) async {
    final Map<String, dynamic> result =
        await _invokeMapRequest(method: mfaEnrollEmailMethod, request: request);

    return MfaEnrollmentChallenge.fromMap(result);
  }

  @override
  Future<MfaEnrollmentChallenge> enrollPush(
      final ApiRequest<MfaEnrollPushOptions> request) async {
    final Map<String, dynamic> result =
        await _invokeMapRequest(method: mfaEnrollPushMethod, request: request);

    return MfaEnrollmentChallenge.fromMap(result);
  }

  @override
  Future<MfaChallenge> challenge(
      final ApiRequest<MfaChallengeOptions> request) async {
    final Map<String, dynamic> result =
        await _invokeMapRequest(method: mfaChallengeMethod, request: request);

    return MfaChallenge.fromMap(result);
  }

  @override
  Future<Credentials> verify(
      final ApiRequest<MfaVerifyOptions> request) async {
    final Map<String, dynamic> result =
        await _invokeMapRequest(method: mfaVerifyMethod, request: request);

    return Credentials.fromMap(result);
  }

  Future<Map<String, dynamic>>
      _invokeMapRequest<TOptions extends RequestOptions>({
    required final String method,
    required final ApiRequest<TOptions> request,
  }) async {
    final Map<String, dynamic>? result;
    try {
      result = await _channel.invokeMapMethod(method, request.toMap());
    } on PlatformException catch (e) {
      throw MfaException.fromPlatformException(e);
    }

    if (result == null) {
      throw const MfaException.unknown('Channel returned null.');
    }

    return result;
  }

  Future<List<dynamic>> _invokeListRequest<TOptions extends RequestOptions>({
    required final String method,
    required final ApiRequest<TOptions> request,
  }) async {
    final List<dynamic>? result;
    try {
      result = await _channel.invokeListMethod(method, request.toMap());
    } on PlatformException catch (e) {
      throw MfaException.fromPlatformException(e);
    }

    if (result == null) {
      throw const MfaException.unknown('Channel returned null.');
    }

    return result;
  }
}
