import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebAuthenticationException', () {
    test('correctly maps from a PlatformException', () async {
      final details = {'details-prop': 'details-value'};
      final platformException = PlatformException(
          code: 'test-code', message: 'test-message', details: details);

      final exception =
          WebAuthenticationException.fromPlatformException(platformException);

      expect(exception.code, 'test-code');
      expect(exception.message, 'test-message');
      expect(exception.details['details-prop'], 'details-value');
    });

    test('isRetryable returns true when _isRetryable flag is true', () {
      final details = {'_isRetryable': true};
      final platformException = PlatformException(
          code: 'OTHER', message: 'test-message', details: details);

      final exception =
          WebAuthenticationException.fromPlatformException(platformException);

      expect(exception.isRetryable, true);
    });

    test('isRetryable returns false when _isRetryable flag is false', () {
      final details = {'_isRetryable': false};
      final platformException = PlatformException(
          code: 'USER_CANCELLED', message: 'test-message', details: details);

      final exception =
          WebAuthenticationException.fromPlatformException(platformException);

      expect(exception.isRetryable, false);
    });

    test('isRetryable returns false when _isRetryable flag is missing', () {
      final details = <String, dynamic>{};
      final platformException = PlatformException(
          code: 'OTHER', message: 'test-message', details: details);

      final exception =
          WebAuthenticationException.fromPlatformException(platformException);

      expect(exception.isRetryable, false);
    });

    test('isUserCancelledException returns true for USER_CANCELLED', () {
      final exception = WebAuthenticationException.fromPlatformException(
          PlatformException(
              code: 'USER_CANCELLED',
              message: '',
              details: <String, dynamic>{}));
      expect(exception.isUserCancelledException, true);
    });

    test('isUserCancelledException returns false for other codes', () {
      final exception = WebAuthenticationException.fromPlatformException(
          PlatformException(
              code: 'a0.authentication_canceled',
              message: '',
              details: <String, dynamic>{}));
      expect(exception.isUserCancelledException, false);
    });

    test('isAuthenticationFailed returns true for AUTHENTICATION_FAILED', () {
      final exception = WebAuthenticationException.fromPlatformException(
          PlatformException(
              code: 'AUTHENTICATION_FAILED',
              message: '',
              details: <String, dynamic>{}));
      expect(exception.isAuthenticationFailed, true);
    });

    test('isCodeExchangeFailed returns true for CODE_EXCHANGE_FAILED', () {
      final exception = WebAuthenticationException.fromPlatformException(
          PlatformException(
              code: 'CODE_EXCHANGE_FAILED',
              message: '',
              details: <String, dynamic>{}));
      expect(exception.isCodeExchangeFailed, true);
    });

    test(
        'isIdTokenValidationFailed returns true for '
        'ID_TOKEN_VALIDATION_FAILED', () {
      final exception = WebAuthenticationException.fromPlatformException(
          PlatformException(
              code: 'ID_TOKEN_VALIDATION_FAILED',
              message: '',
              details: <String, dynamic>{}));
      expect(exception.isIdTokenValidationFailed, true);
    });

    test(
        'isTransactionActiveAlready returns true for '
        'TRANSACTION_ACTIVE_ALREADY', () {
      final exception = WebAuthenticationException.fromPlatformException(
          PlatformException(
              code: 'TRANSACTION_ACTIVE_ALREADY',
              message: '',
              details: <String, dynamic>{}));
      expect(exception.isTransactionActiveAlready, true);
    });
  });
}
