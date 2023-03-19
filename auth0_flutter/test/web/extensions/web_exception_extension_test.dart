@Tags(['browser'])

import 'dart:js';
import 'dart:js_util';
import 'package:auth0_flutter/src/web/extensions/web_exception_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Object createJsException(final String error, final String description,
      {final Map<String, dynamic>? details}) {
    final jsObject = newObject<JsObject>();
    setProperty(jsObject, 'error', error);
    setProperty(jsObject, 'error_description', description);

    if (details != null) {
      for (final element in details.entries) {
        setProperty(jsObject, element.key, element.value);
      }
    }

    return jsObject;
  }

  test('mfa_required exception is created', () {
    final exception = createJsException('mfa_required', 'MFA is required',
        details: {'mfaToken': 'abc123'});

    final webException = WebExceptionExtension.fromJsObject(exception);

    expect(webException.code, 'MFA_REQUIRED');
    expect(webException.message, 'MFA is required');
    expect(webException.details['mfaToken'], 'abc123');
  });
}
