import 'package:flutter/services.dart';

import '../extensions/map_extensions.dart';

class ApiException implements Exception {
  static const _unknown = 'UNKNOWN';

  final String code;
  final String message;
  final Map<String, dynamic> details;
  final Map<dynamic, dynamic> _errorFlags;

  const ApiException(this.code, this.message, this.details, this._errorFlags);
  const ApiException.unknown(this.message)
      : code = ApiException._unknown,
        details = const {},
        _errorFlags = const {};
  factory ApiException.fromPlatformException(final PlatformException e) {
    final details = Map<String, dynamic>.from(
        (e.details ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>);
    final errorFlags = details['_errorFlags'] as Map<dynamic, dynamic>;

    details.remove('_errorFlags');

    return ApiException(
        e.code,
        e.message ?? '', // Errors from native should always have a message
        details,
        errorFlags);
  }

  @override
  String toString() => '$code: $message';

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
