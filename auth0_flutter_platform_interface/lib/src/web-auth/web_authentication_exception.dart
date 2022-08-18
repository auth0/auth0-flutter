import 'package:flutter/services.dart';

import '../auth0_exception.dart';
import '../extensions/exception_extensions.dart';

class WebAuthenticationException extends Auth0Exception {
  const WebAuthenticationException(final String code, final String message,
      final Map<String, dynamic> details)
      : super(code, message, details);

  const WebAuthenticationException.unknown(final String message)
      : super.unknown(message);

  WebAuthenticationException.fromPlatformException(final PlatformException e)
      : this(e.code, e.messageString, e.detailsMap);
}
