import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MfaException exceptionWith({
    required final String code,
    final bool isNetworkError = false,
    final int statusCode = 400,
  }) =>
      MfaException.fromPlatformException(PlatformException(
        code: code,
        message: code,
        details: <String, dynamic>{
          '_statusCode': statusCode,
          '_errorFlags': {'isNetworkError': isNetworkError},
        },
      ));

  group('MfaException getters', () {
    test('isMfaTokenExpired is true only for expired_token', () {
      expect(exceptionWith(code: 'expired_token').isMfaTokenExpired, isTrue);
      expect(exceptionWith(code: 'invalid_grant').isMfaTokenExpired, isFalse);
    });

    test('isInvalidRequest is true only for invalid_request', () {
      expect(exceptionWith(code: 'invalid_request').isInvalidRequest, isTrue);
      expect(exceptionWith(code: 'expired_token').isInvalidRequest, isFalse);
    });

    test('isInvalidCode is true for invalid_grant and invalid_otp_code', () {
      expect(exceptionWith(code: 'invalid_grant').isInvalidCode, isTrue);
      expect(exceptionWith(code: 'invalid_otp_code').isInvalidCode, isTrue);
      expect(exceptionWith(code: 'expired_token').isInvalidCode, isFalse);
    });

    test('isNetworkError and isRetryable reflect the error flag', () {
      final networkError =
          exceptionWith(code: 'network_error', isNetworkError: true);
      expect(networkError.isNetworkError, isTrue);
      expect(networkError.isRetryable, isTrue);

      final other = exceptionWith(code: 'invalid_request');
      expect(other.isNetworkError, isFalse);
      expect(other.isRetryable, isFalse);
    });

    test('statusCode and details are parsed from the platform exception', () {
      final exception = exceptionWith(code: 'invalid_request', statusCode: 403);
      expect(exception.statusCode, 403);
      // Internal bookkeeping keys are stripped from the public details map.
      expect(exception.details.containsKey('_statusCode'), isFalse);
      expect(exception.details.containsKey('_errorFlags'), isFalse);
    });
  });
}
