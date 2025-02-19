import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

@JS('Object.keys')
external JSArray<JSString> keys(final JSObject o);

extension WebExceptionExtension on WebException {
  static WebException fromJsObject(final Object jsException) {
    final error = jsException.toJSBox.getProperty<JSString>('error'.toJS);
    final description =
        jsException.toJSBox.getProperty<JSString>('error_description'.toJS);
    final Map<String, JSAny?> details = {};

    keys(jsException.toJSBox).toDart.forEach((final key) {
      if (key == 'error'.toJS || key.toDart == 'error_description'.toJS) return;
      details[key.toDart] = jsException.toJSBox.getProperty<JSAny?>(key);
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
        return WebException.authenticationError(error.toDart,
            description.toDart, {'state': details['state']});
      case 'mfa_required':
        return WebException.mfaError(description.toDart,
            jsException.toJSBox.getProperty('mfaToken'.toJS));
      case 'timeout':
        return WebException.timeout(description.toDart);
      case 'cancelled':
        return WebException.popupClosed(description.toDart);
      case 'missing_refresh_token':
        return WebException.missingRefreshToken(description.toDart);
    }

    return WebException(error.toDart, description.toDart, details);
  }
}
