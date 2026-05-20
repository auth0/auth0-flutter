import 'package:flutter/services.dart';

import '../auth0_exception.dart';
import '../extensions/exception_extensions.dart';
import '../extensions/map_extensions.dart';

class MyAccountException extends Auth0Exception {
  static const _statusCodeKey = '_statusCode';
  static const _errorFlagsKey = '_errorFlags';

  final int statusCode;
  final Map<dynamic, dynamic> _errorFlags;

  const MyAccountException(final String code, final String message,
      final Map<String, dynamic> details, this._errorFlags, this.statusCode)
      : super(code, message, details);

  const MyAccountException.unknown(final String message)
      : _errorFlags = const {},
        statusCode = 0,
        super.unknown(message);

  factory MyAccountException.fromPlatformException(final PlatformException e) {
    final Map<String, dynamic> errorDetails = e.detailsMap;
    final statusCode = errorDetails.getOrDefault(_statusCodeKey, 0);
    final errorFlags =
        errorDetails.getOrDefault(_errorFlagsKey, <dynamic, dynamic>{});

    errorDetails.remove(_statusCodeKey);
    errorDetails.remove(_errorFlagsKey);

    return MyAccountException(
        e.code, e.messageString, errorDetails, errorFlags, statusCode);
  }

  bool get isNetworkError => _errorFlags.getBooleanOrFalse('isNetworkError');
  bool get isRetryable => isNetworkError;
}
