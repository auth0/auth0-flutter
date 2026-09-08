import 'package:flutter/services.dart';

import '../auth0_exception.dart';
import '../extensions/exception_extensions.dart';
import '../extensions/map_extensions.dart';

class WebAuthenticationException extends Auth0Exception {
  const WebAuthenticationException(final String code, final String message,
      final Map<String, dynamic> details)
      : super(code, message, details);

  const WebAuthenticationException.unknown(final String message)
      : super.unknown(message);

  WebAuthenticationException.fromPlatformException(final PlatformException e)
      : this(e.code, e.messageString, e.detailsMap);

  bool get isUserCancelledException => code == 'USER_CANCELLED';

  bool get isAuthenticationFailed => code == 'AUTHENTICATION_FAILED';

  bool get isCodeExchangeFailed => code == 'CODE_EXCHANGE_FAILED';

  bool get isIdTokenValidationFailed => code == 'ID_TOKEN_VALIDATION_FAILED';

  bool get isTransactionActiveAlready => code == 'TRANSACTION_ACTIVE_ALREADY';

  bool get isRetryable => details.getBooleanOrFalse('_isRetryable');
}
