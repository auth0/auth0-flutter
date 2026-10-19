@Tags(['browser'])
import 'dart:js_interop';

import 'package:auth0_flutter/src/web/extensions/my_account_extensions.dart';
import 'package:auth0_flutter/src/web/js_interop.dart' as interop;
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

JSObject _jsObject(Map<String, Object?> map) => map.jsify()! as JSObject;

void main() {
  group('myAccountApiBaseFor', () {
    test('prepends https:// to a bare domain', () {
      expect(myAccountApiBaseFor('tenant.auth0.com'),
          'https://tenant.auth0.com/me/');
    });

    test('keeps an existing https:// scheme', () {
      expect(myAccountApiBaseFor('https://tenant.auth0.com'),
          'https://tenant.auth0.com/me/');
    });

    test('keeps an existing http:// scheme', () {
      expect(myAccountApiBaseFor('http://localhost:3000'),
          'http://localhost:3000/me/');
    });
  });

  group('myAccountAuthenticationMethodLocation', () {
    test('appends the encoded authentication method id', () {
      expect(
          myAccountAuthenticationMethodLocation(
              'https://tenant.auth0.com/me/', 'phone|dev_123'),
          'https://tenant.auth0.com/me/v1/authentication-methods/'
          'phone%7Cdev_123');
    });
  });

  group('AuthenticationMethodWebExtension', () {
    test('maps all fields', () {
      final js = _jsObject({
        'id': 'phone|dev_1',
        'type': 'phone',
        'name': 'My phone',
        'phone_number': '+15555550100',
        'preferred_authentication_method': 'sms',
        'created_at': '2026-01-02T03:04:05.000Z',
        'last_auth_at': '2026-02-03T04:05:06.000Z',
        'confirmed': true,
        'usage': ['secondary'],
      }) as interop.MyAccountAuthenticationMethodJS;

      final method = AuthenticationMethodWebExtension.fromWeb(js);

      expect(method.id, 'phone|dev_1');
      expect(method.type, 'phone');
      expect(method.name, 'My phone');
      expect(method.phoneNumber, '+15555550100');
      expect(method.preferredAuthenticationMethod, 'sms');
      expect(method.createdAt, DateTime.utc(2026, 1, 2, 3, 4, 5));
      expect(method.lastAuthAt, DateTime.utc(2026, 2, 3, 4, 5, 6));
      expect(method.confirmed, true);
      expect(method.usage, ['secondary']);
    });

    test('leaves missing optional fields null', () {
      final js = _jsObject({'id': 'email|dev_1', 'type': 'email'})
          as interop.MyAccountAuthenticationMethodJS;

      final method = AuthenticationMethodWebExtension.fromWeb(js);

      expect(method.id, 'email|dev_1');
      expect(method.email, isNull);
      expect(method.createdAt, isNull);
      expect(method.lastAuthAt, isNull);
      expect(method.confirmed, isNull);
      expect(method.usage, isNull);
    });
  });

  test('FactorWebExtension maps the type and usage', () {
    final js = _jsObject({
      'type': 'totp',
      'usage': ['secondary']
    }) as interop.MyAccountFactorJS;

    final factor = FactorWebExtension.fromWeb(js);

    expect(factor.type, 'totp');
    expect(factor.usage, ['secondary']);
  });

  group('EnrollmentChallengeWebExtension', () {
    test('maps a TOTP challenge the same way as Android and iOS', () {
      final js = _jsObject({
        'id': 'totp|dev_1',
        'auth_session': 'session',
        'barcode_uri': 'otpauth://totp/tenant:user?secret=ABC',
        'manual_input_code': 'ABC',
      }) as interop.MyAccountEnrollmentChallengeJS;

      final challenge = EnrollmentChallengeWebExtension.fromWeb(js);

      expect(challenge.id, 'totp|dev_1');
      expect(challenge.authSession, 'session');
      expect(challenge.totpSecret, 'ABC');
      expect(challenge.totpUri, 'otpauth://totp/tenant:user?secret=ABC');
      expect(challenge.barcodeUri, 'otpauth://totp/tenant:user?secret=ABC');
      expect(challenge.recoveryCode, isNull);
    });

    test('maps a recovery code challenge', () {
      final js = _jsObject({
        'id': 'recovery-code|dev_1',
        'auth_session': 'session',
        'recovery_code': 'ABCD1234',
      }) as interop.MyAccountEnrollmentChallengeJS;

      final challenge = EnrollmentChallengeWebExtension.fromWeb(js);

      expect(challenge.recoveryCode, 'ABCD1234');
      expect(challenge.totpSecret, isNull);
      expect(challenge.barcodeUri, isNull);
    });
  });

  group('MyAccountExceptionWebExtension', () {
    test('maps a MyAccountApiError', () {
      final exception = MyAccountExceptionWebExtension.fromJsObject(_jsObject({
        'name': 'MyAccountApiError',
        'message': 'The phone number is invalid',
        'type': 'https://auth0.com/api-errors/A0E-400-0001',
        'status': 400,
        'title': 'Bad Request',
        'detail': 'The phone number is invalid',
        'validation_errors': [
          {'detail': 'Invalid format', 'field': 'phone_number'}
        ],
      }));

      expect(exception.code, 'https://auth0.com/api-errors/A0E-400-0001');
      expect(exception.message, 'The phone number is invalid');
      expect(exception.statusCode, 400);
      expect(exception.title, 'Bad Request');
      expect(exception.detail, 'The phone number is invalid');
      expect(exception.details['validation_errors'], [
        {'detail': 'Invalid format', 'field': 'phone_number'}
      ]);
      expect(exception.isNetworkError, false);
      expect(exception.isRetryable, false);
    });

    test('uses the title as the message when there is no detail', () {
      final exception = MyAccountExceptionWebExtension.fromJsObject(_jsObject({
        'name': 'MyAccountApiError',
        'type': 'https://auth0.com/api-errors/A0E-401-0001',
        'status': 401,
        'title': 'Unauthorized',
        'detail': '',
      }));

      expect(exception.message, 'Unauthorized');
      expect(exception.statusCode, 401);
      expect(exception.details, isEmpty);
    });

    test('maps a fetch TypeError to a retryable network error', () {
      final exception = MyAccountExceptionWebExtension.fromJsObject(
          _jsObject({'name': 'TypeError', 'message': 'Failed to fetch'}));

      expect(exception.code, 'network_error');
      expect(exception.message, 'Failed to fetch');
      expect(exception.statusCode, 0);
      expect(exception.isNetworkError, true);
      expect(exception.isRetryable, true);
    });

    test('maps any other error to an unknown error', () {
      final exception = MyAccountExceptionWebExtension.fromJsObject(
          _jsObject({'name': 'Error', 'message': 'Something went wrong'}));

      expect(exception, isA<MyAccountException>());
      expect(exception.message, 'Something went wrong');
      expect(exception.isNetworkError, false);
    });
  });
}
