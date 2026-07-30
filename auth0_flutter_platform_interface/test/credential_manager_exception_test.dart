import 'package:auth0_flutter_platform_interface/src/credentials-manager/credentials_manager_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CredentialsManagerException', () {
    test('correctly maps from a PlatformException', () async {
      final details = {'details-prop': 'details-value'};
      final platformException = PlatformException(
          code: 'test-code', message: 'test-message', details: details);

      final exception =
          CredentialsManagerException.fromPlatformException(platformException);

      expect(exception.code, 'test-code');
      expect(exception.message, 'test-message');
      expect(exception.details['details-prop'], 'details-value');
    });

    test('isRetryable returns true when _isRetryable flag is true', () {
      final details = {'_isRetryable': true};
      final platformException = PlatformException(
          code: 'RENEW_FAILED', message: 'test-message', details: details);

      final exception =
          CredentialsManagerException.fromPlatformException(platformException);

      expect(exception.isRetryable, true);
    });

    test('isRetryable returns false when _isRetryable flag is false', () {
      final details = {'_isRetryable': false};
      final platformException = PlatformException(
          code: 'RENEW_FAILED', message: 'test-message', details: details);

      final exception =
          CredentialsManagerException.fromPlatformException(platformException);

      expect(exception.isRetryable, false);
    });

    test('isRetryable returns false when _isRetryable flag is missing', () {
      final details = <String, dynamic>{};
      final platformException = PlatformException(
          code: 'RENEW_FAILED', message: 'test-message', details: details);

      final exception =
          CredentialsManagerException.fromPlatformException(platformException);

      expect(exception.isRetryable, false);
    });

    test('isSessionExpired returns true for the SESSION_EXPIRED code', () {
      final exception = CredentialsManagerException.fromPlatformException(
          PlatformException(code: 'SESSION_EXPIRED'));

      expect(exception.isSessionExpired, true);
    });

    test('isSessionExpired returns true for the session_expiry message', () {
      final exception = CredentialsManagerException.fromPlatformException(
          PlatformException(
              code: 'The session has reached the session_expiry ceiling set '
                  'by the identity provider and is no longer valid. The user '
                  'must re-authenticate.'));

      expect(exception.isSessionExpired, true);
    });

    test('isSessionExpired returns false for a non-matching error', () {
      final exception = CredentialsManagerException.fromPlatformException(
          PlatformException(code: 'NO_CREDENTIALS'));

      expect(exception.isSessionExpired, false);
      expect(exception.isNoCredentialsFound, true);
    });
  });
}
