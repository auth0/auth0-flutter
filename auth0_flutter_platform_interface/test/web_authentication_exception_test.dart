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
  });
}
