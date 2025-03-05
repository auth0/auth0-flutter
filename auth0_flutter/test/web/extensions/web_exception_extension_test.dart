@Tags(['browser'])
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:auth0_flutter/src/web/extensions/web_exception_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  JSObject createJsException(final String error, final String description,
      {final Map<String, dynamic>? additionalProps}) {
    final jsObject = JSObject();
    jsObject.setProperty('error'.toJS, error.toJS);
    jsObject.setProperty('error_description'.toJS, description.toJS);

    if (additionalProps != null) {
      for (final element in additionalProps.entries) {
        jsObject.setProperty(element.key.toJS, element.value as JSAny);
      }
    }

    return jsObject;
  }

  test('additional props are added to the details collection', () {
    final exception = createJsException(
      'authentication_error',
      'A test authentication error',
      additionalProps: {
        'prop-1': 'Property 1',
        'prop-2': 'Property 2',
      },
    );

    final webException = WebExceptionExtension.fromJsObject(exception);

    expect(webException.code, 'authentication_error');
    expect(webException.message, 'A test authentication error');
    expect(webException.details['prop-1'], 'Property 1');
    expect(webException.details['prop-2'], 'Property 2');
  });

  test('mfa_required exception is created', () {
    final exception = createJsException(
      'mfa_required',
      'MFA is required',
      additionalProps: {'mfaToken': 'abc123'},
    );

    final webException = WebExceptionExtension.fromJsObject(exception);
    expect(webException.code, 'MFA_REQUIRED');
    expect(webException.message, 'MFA is required');
    expect(webException.details['mfaToken'], 'abc123');
  });

  test('timeout error is created', () {
    final exception = createJsException('timeout', 'Timeout');
    final webException = WebExceptionExtension.fromJsObject(exception);

    expect(webException.code, 'TIMEOUT');
    expect(webException.message, 'Timeout');
    expect(webException.details, <String, dynamic>{});
  });

  test('missing_refresh_token is created', () {
    final exception = createJsException(
      'missing_refresh_token',
      'Missing refresh token',
    );
    final webException = WebExceptionExtension.fromJsObject(exception);

    expect(webException.code, 'MISSING_REFRESH_TOKEN');
    expect(webException.message, 'Missing refresh token');
    expect(webException.details, <String, dynamic>{});
  });

  test('popup cancelled is created', () {
    final exception = createJsException('cancelled', 'Popup was closed');
    final webException = WebExceptionExtension.fromJsObject(exception);

    expect(webException.code, 'POPUP_CLOSED');
    expect(webException.message, 'Popup was closed');
    expect(webException.details, <String, dynamic>{});
  });

  final codes = [
    'invalid_request',
    'invalid_scope',
    'invalid_client',
    'requires_validation',
    'unauthorized_client',
    'access_denied',
    'invalid_grant',
    'endpoint_disabled',
    'method_not_allowed',
    'too_many_requests',
    'unsupported_response_type',
    'unsupported_grant_type',
    'temporarily_unavailable'
  ];

  for (final code in codes) {
    test('$code is captured as AUTHENTICATION_ERROR', () {
      final exception = createJsException(code, '$code was raised');
      final webException = WebExceptionExtension.fromJsObject(exception);

      expect(webException.code, 'AUTHENTICATION_ERROR');
      expect(webException.message, '$code was raised');
      expect(webException.details['code'], code);
    });
  }

  test('AUTHENTICATION_ERROR is captured with state only', () {
    final exception = createJsException(
      'invalid_grant',
      'Invalid grant',
      additionalProps: {'state': '123', 'appState': '456'},
    );

    final webException = WebExceptionExtension.fromJsObject(exception);

    expect(webException.code, 'AUTHENTICATION_ERROR');
    expect(webException.message, 'Invalid grant');
    expect(webException.details['code'], 'invalid_grant');
    expect(webException.details['state'], '123');
    expect(webException.details['appState'], isNull);
  });
}
