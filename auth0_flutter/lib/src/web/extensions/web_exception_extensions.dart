import 'dart:js';
import 'dart:js_util';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

extension WebExceptionExtension on WebException {
  static WebException fromJsObject(final Object jsException) {
    final error = getProperty<String>(jsException, 'error');
    final description = getProperty<String>(jsException, 'error_description');
    final Map<String, dynamic> details = {};

    objectKeys(jsException).forEach((final key) {
      if (key == 'error' || key == 'error_description') return;
      details[key as String] = getProperty<dynamic>(jsException, key);
    });

    switch (error) {
      case 'mfa_required':
        return WebException.mfaError(
            description, getProperty(jsException, 'mfaToken'));

      case 'timeout':
        return WebException.timeout(description);
    }

    return WebException(error, description, details);
  }
}
