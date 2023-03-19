@Tags(['browser'])

import 'dart:js';
import 'dart:js_util';
import 'package:auth0_flutter/src/web/extensions/web_exception_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Object createJsException(final String error, final String description,
      {final Map<String, dynamic>? additionalProps}) {
    final jsObject = newObject<JsObject>();
    setProperty(jsObject, 'error', error);
    setProperty(jsObject, 'error_description', description);

    if (additionalProps != null) {
      for (final element in additionalProps.entries) {
        setProperty(jsObject, element.key, element.value);
      }
    }

    return jsObject;
  }

  test('additional props are added to the details collection', () {
    final exception = createJsException(
        'authentication_error', 'A test authentication error',
        additionalProps: {'prop-1': 'Property 1', 'prop-2': 'Property 2'});

    final webException = WebExceptionExtension.fromJsObject(exception);

    expect(webException.code, 'authentication_error');
    expect(webException.message, 'A test authentication error');
    expect(webException.details['prop-1'], 'Property 1');
    expect(webException.details['prop-2'], 'Property 2');
  });

  test('mfa_required exception is created', () {
    final exception = createJsException('mfa_required', 'MFA is required',
        additionalProps: {'mfaToken': 'abc123'});

    final webException = WebExceptionExtension.fromJsObject(exception);

    expect(webException.code, 'MFA_REQUIRED');
    expect(webException.message, 'MFA is required');
    expect(webException.details['mfaToken'], 'abc123');
  });
}
