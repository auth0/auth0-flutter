import 'package:flutter/services.dart';

import '../auth0_exception.dart';
import '../extensions/exception_extensions.dart';

class WebAuthException extends Auth0Exception {
  const WebAuthException(final String code, final String message,
      final Map<String, dynamic> details)
      : super(code, message, details);

  const WebAuthException.unknown(final String message) : super.unknown(message);
  
  factory WebAuthException.fromPlatformException(final PlatformException e) =>
      WebAuthException(e.code, e.messageString, e.detailsMap);
}
