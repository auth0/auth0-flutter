import 'package:flutter/services.dart';

import '../auth0_exception.dart';
import '../extensions/exception_extensions.dart';
import '../extensions/map_extensions.dart';

class MyAccountException extends Auth0Exception {
  static const _statusCodeKey = '_statusCode';
  static const _titleKey = '_title';
  static const _detailKey = '_detail';
  static const _errorFlagsKey = '_errorFlags';

  final int statusCode;
  final String title;
  final String detail;
  final Map<dynamic, dynamic> _errorFlags;

  const MyAccountException(final String code, final String message,
      final Map<String, dynamic> details, this._errorFlags, this.statusCode,
      this.title, this.detail)
      : super(code, message, details);

  const MyAccountException.unknown(final String message)
      : _errorFlags = const {},
        statusCode = 0,
        title = '',
        detail = '',
        super.unknown(message);

  factory MyAccountException.fromPlatformException(final PlatformException e) {
    final Map<String, dynamic> errorDetails = e.detailsMap;
    final statusCode = errorDetails.getOrDefault(_statusCodeKey, 0);
    final title = errorDetails.getOrDefault<String>(_titleKey, '');
    final detail = errorDetails.getOrDefault<String>(_detailKey, '');
    final errorFlags =
        errorDetails.getOrDefault(_errorFlagsKey, <dynamic, dynamic>{});

    errorDetails.remove(_statusCodeKey);
    errorDetails.remove(_titleKey);
    errorDetails.remove(_detailKey);
    errorDetails.remove(_errorFlagsKey);

    return MyAccountException(
        e.code, e.messageString, errorDetails, errorFlags, statusCode,
        title, detail);
  }

  bool get isNetworkError => _errorFlags.getBooleanOrFalse('isNetworkError');
  bool get isRetryable => isNetworkError;
}
