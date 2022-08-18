import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiException', () {
    test('correctly maps from a PlatformException', () async {
      final details = {'details-prop': 'details-value'};
      final platformException = PlatformException(
          code: 'test-code', message: 'test-message', details: details);

      final exception = ApiException.fromPlatformException(platformException);

      expect(exception.code, 'test-code');
      expect(exception.message, 'test-message');
      expect(exception.details['details-prop'], 'details-value');
    });

    test('removes _statusCode from details', () async {
      final details = {
        'details-prop': 'details-value',
        '_statusCode': 50
      };
      final platformException =
          PlatformException(code: 'test-code', details: details);

      final exception = ApiException.fromPlatformException(platformException);

      expect(exception.details['details-prop'], 'details-value');
      expect(exception.details['_statusCode'], null);
    });

     test('correctly maps statusCode', () async {
      final details = {
        'details-prop': 'details-value',
        '_statusCode': 50
      };
      final platformException =
          PlatformException(code: 'test-code', details: details);

      final exception = ApiException.fromPlatformException(platformException);

      expect(exception.statusCode, 50);
    });

    test('sets statusCode to 0 when omitted', () async {
      final details = {
        'details-prop': 'details-value',
      };
      final platformException =
          PlatformException(code: 'test-code', details: details);

      final exception = ApiException.fromPlatformException(platformException);

      expect(exception.statusCode, 0);
    });


    test('removes _errorFlags from details', () async {
      final details = {
        'details-prop': 'details-value',
        '_errorFlags': {'isMultifactorRequired': true}
      };
      final platformException =
          PlatformException(code: 'test-code', details: details);

      final exception = ApiException.fromPlatformException(platformException);

      expect(exception.details['details-prop'], 'details-value');
      expect(exception.details['_errorFlags'], null);
    });

    test('correctly maps _errorFlags when true', () async {
      final details = {
        'details-prop': 'details-value',
        '_errorFlags': {
          'isMultifactorRequired': true,
          'isMultifactorEnrollRequired': true,
          'isMultifactorCodeInvalid': true,
          'isMultifactorTokenInvalid': true,
          'isPasswordNotStrongEnough': true,
          'isPasswordAlreadyUsed': true,
          'isRuleError': true,
          'isInvalidCredentials': true,
          'isRefreshTokenDeleted': true,
          'isAccessDenied': true,
          'isTooManyAttempts': true,
          'isVerificationRequired': true,
          'isNetworkError': true,
          'isBrowserAppNotAvailable': true,
          'isPKCENotAvailable': true,
          'isInvalidAuthorizeURL': true,
          'isInvalidConfiguration': true,
          'isCanceled': true,
          'isLoginRequired': true,
          'isPasswordLeaked': true
        }
      };
      final platformException =
          PlatformException(code: 'test-code', details: details);

      final exception = ApiException.fromPlatformException(platformException);

      expect(exception.isMultifactorRequired, true);
      expect(exception.isMultifactorEnrollRequired, true);
      expect(exception.isMultifactorCodeInvalid, true);
      expect(exception.isMultifactorTokenInvalid, true);
      expect(exception.isPasswordNotStrongEnough, true);
      expect(exception.isPasswordAlreadyUsed, true);
      expect(exception.isRuleError, true);
      expect(exception.isInvalidCredentials, true);
      expect(exception.isRefreshTokenDeleted, true);
      expect(exception.isAccessDenied, true);
      expect(exception.isTooManyAttempts, true);
      expect(exception.isVerificationRequired, true);
      expect(exception.isNetworkError, true);
      expect(exception.isBrowserAppNotAvailable, true);
      expect(exception.isPkceNotAvailable, true);
      expect(exception.isInvalidAuthorizeUrl, true);
      expect(exception.isInvalidConfiguration, true);
      expect(exception.isCanceled, true);
      expect(exception.isLoginRequired, true);
      expect(exception.isPasswordLeaked, true);
    });

    test('correctly maps _errorFlags when false', () async {
      final details = {
        'details-prop': 'details-value',
        '_errorFlags': {
          'isMultifactorRequired': false,
          'isMultifactorEnrollRequired': false,
          'isMultifactorCodeInvalid': false,
          'isMultifactorTokenInvalid': false,
          'isPasswordNotStrongEnough': false,
          'isPasswordAlreadyUsed': false,
          'isRuleError': false,
          'isInvalidCredentials': false,
          'isRefreshTokenDeleted': false,
          'isAccessDenied': false,
          'isTooManyAttempts': false,
          'isVerificationRequired': false,
          'isNetworkError': false,
          'isBrowserAppNotAvailable': false,
          'isPKCENotAvailable': false,
          'isInvalidAuthorizeURL': false,
          'isInvalidConfiguration': false,
          'isCanceled': false,
          'isLoginRequired': false,
          'isPasswordLeaked': false
        }
      };
      final platformException =
          PlatformException(code: 'test-code', details: details);

      final exception = ApiException.fromPlatformException(platformException);

      expect(exception.isMultifactorRequired, false);
      expect(exception.isMultifactorEnrollRequired, false);
      expect(exception.isMultifactorCodeInvalid, false);
      expect(exception.isMultifactorTokenInvalid, false);
      expect(exception.isPasswordNotStrongEnough, false);
      expect(exception.isPasswordAlreadyUsed, false);
      expect(exception.isRuleError, false);
      expect(exception.isInvalidCredentials, false);
      expect(exception.isRefreshTokenDeleted, false);
      expect(exception.isAccessDenied, false);
      expect(exception.isTooManyAttempts, false);
      expect(exception.isVerificationRequired, false);
      expect(exception.isNetworkError, false);
      expect(exception.isBrowserAppNotAvailable, false);
      expect(exception.isPkceNotAvailable, false);
      expect(exception.isInvalidAuthorizeUrl, false);
      expect(exception.isInvalidConfiguration, false);
      expect(exception.isCanceled, false);
      expect(exception.isLoginRequired, false);
      expect(exception.isPasswordLeaked, false);
    });
  });

  test('correctly maps _errorFlags when properties omitted', () async {
    final details = {
      'details-prop': 'details-value',
      // ignore: inference_failure_on_collection_literal
      '_errorFlags': {}
    };
    final platformException =
        PlatformException(code: 'test-code', details: details);

    final exception = ApiException.fromPlatformException(platformException);

    expect(exception.isMultifactorRequired, false);
    expect(exception.isMultifactorEnrollRequired, false);
    expect(exception.isMultifactorCodeInvalid, false);
    expect(exception.isMultifactorTokenInvalid, false);
    expect(exception.isPasswordNotStrongEnough, false);
    expect(exception.isPasswordAlreadyUsed, false);
    expect(exception.isRuleError, false);
    expect(exception.isInvalidCredentials, false);
    expect(exception.isRefreshTokenDeleted, false);
    expect(exception.isAccessDenied, false);
    expect(exception.isTooManyAttempts, false);
    expect(exception.isVerificationRequired, false);
    expect(exception.isNetworkError, false);
    expect(exception.isBrowserAppNotAvailable, false);
    expect(exception.isPkceNotAvailable, false);
    expect(exception.isInvalidAuthorizeUrl, false);
    expect(exception.isInvalidConfiguration, false);
    expect(exception.isCanceled, false);
    expect(exception.isLoginRequired, false);
    expect(exception.isPasswordLeaked, false);
  });

  test('correctly maps _errorFlags when not present', () async {
    final details = {
      'details-prop': 'details-value'
    };
    final platformException =
        PlatformException(code: 'test-code', details: details);

    final exception = ApiException.fromPlatformException(platformException);

    expect(exception.isMultifactorRequired, false);
    expect(exception.isMultifactorEnrollRequired, false);
    expect(exception.isMultifactorCodeInvalid, false);
    expect(exception.isMultifactorTokenInvalid, false);
    expect(exception.isPasswordNotStrongEnough, false);
    expect(exception.isPasswordAlreadyUsed, false);
    expect(exception.isRuleError, false);
    expect(exception.isInvalidCredentials, false);
    expect(exception.isRefreshTokenDeleted, false);
    expect(exception.isAccessDenied, false);
    expect(exception.isTooManyAttempts, false);
    expect(exception.isVerificationRequired, false);
    expect(exception.isNetworkError, false);
    expect(exception.isBrowserAppNotAvailable, false);
    expect(exception.isPkceNotAvailable, false);
    expect(exception.isInvalidAuthorizeUrl, false);
    expect(exception.isInvalidConfiguration, false);
    expect(exception.isCanceled, false);
    expect(exception.isLoginRequired, false);
    expect(exception.isPasswordLeaked, false);
  });
}
