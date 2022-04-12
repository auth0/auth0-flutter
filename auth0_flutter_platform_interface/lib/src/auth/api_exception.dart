import 'package:flutter/services.dart';

import '../auth0_exception.dart';
import '../extensions/exception_extensions.dart';
import '../extensions/map_extensions.dart';

class ApiException extends Auth0Exception {
  static const _errorFlagsKey = '_errorFlags';

  final Map<dynamic, dynamic> _errorFlags;

  const ApiException(final String code, final String message,
      final Map<String, dynamic> details, this._errorFlags)
      : super(code, message, details);

  const ApiException.unknown(final String message)
      : _errorFlags = const {},
        super.unknown(message);

  factory ApiException.fromPlatformException(final PlatformException e) {
    final Map<String, dynamic> errorDetails = e.detailsMap;
    final errorFlags =
        errorDetails.getOrDefault(_errorFlagsKey, <dynamic, dynamic>{});
    errorDetails.remove(_errorFlagsKey);
    return ApiException(e.code, e.messageString, errorDetails, errorFlags);
  }

  bool get isMultifactorRequired =>
      _errorFlags.getBooleanOrFalse('isMultifactorRequired');
  bool get isMultifactorEnrollRequired =>
      _errorFlags.getBooleanOrFalse('isMultifactorEnrollRequired');
  bool get isMultifactorCodeInvalid =>
      _errorFlags.getBooleanOrFalse('isMultifactorCodeInvalid');
  bool get isMultifactorTokenInvalid =>
      _errorFlags.getBooleanOrFalse('isMultifactorTokenInvalid');
  bool get isPasswordNotStrongEnough =>
      _errorFlags.getBooleanOrFalse('isPasswordNotStrongEnough');
  bool get isPasswordAlreadyUsed =>
      _errorFlags.getBooleanOrFalse('isPasswordAlreadyUsed');
  bool get isRuleError => _errorFlags.getBooleanOrFalse('isRuleError');
  bool get isInvalidCredentials =>
      _errorFlags.getBooleanOrFalse('isInvalidCredentials');
  bool get isRefreshTokenDeleted =>
      _errorFlags.getBooleanOrFalse('isRefreshTokenDeleted');
  bool get isAccessDenied => _errorFlags.getBooleanOrFalse('isAccessDenied');
  bool get isTooManyAttempts =>
      _errorFlags.getBooleanOrFalse('isTooManyAttempts');
  bool get isVerificationRequired =>
      _errorFlags.getBooleanOrFalse('isVerificationRequired');
  bool get isNetworkError => _errorFlags.getBooleanOrFalse('isNetworkError');
  bool get isBrowserAppNotAvailable =>
      _errorFlags.getBooleanOrFalse('isBrowserAppNotAvailable');
  bool get isPKCENotAvailable =>
      _errorFlags.getBooleanOrFalse('isPKCENotAvailable');
  bool get isInvalidAuthorizeURL =>
      _errorFlags.getBooleanOrFalse('isInvalidAuthorizeURL');
  bool get isInvalidConfiguration =>
      _errorFlags.getBooleanOrFalse('isInvalidConfiguration');
  bool get isCanceled => _errorFlags.getBooleanOrFalse('isCanceled');
  bool get isPasswordLeaked =>
      _errorFlags.getBooleanOrFalse('isPasswordLeaked');
  bool get isLoginRequired => _errorFlags.getBooleanOrFalse('isLoginRequired');
}
