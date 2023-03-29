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
      case 'invalid_request':
      case 'invalid_scope':
      case 'invalid_client':
      case 'requires_validation':
      case 'unauthorized_client':
      case 'access_denied':
      case 'invalid_grant':
      case 'endpoint_disabled':
      case 'method_not_allowed':
      case 'too_many_requests':
      case 'unsupported_response_type':
      case 'unsupported_grant_type':
      case 'temporarily_unavailable':
        return WebException.authenticationError(error, description);
      case 'mfa_required':
        return WebException.mfaError(
            description, getProperty(jsException, 'mfaToken'));
      case 'timeout':
        return WebException.timeout(description);
      case 'cancelled':
        return WebException.popupClosed(description);
      case 'missing_refresh_token':
        return WebException.missingRefreshToken(description);
    }

    // Other rules
    if (details.containsKey('state')) {
      return WebException('AUTHENTICATION_ERROR', description, details);
    }

    return WebException(error, description, details);
  }
}
