import 'package:flutter/services.dart';

class ApiException implements Exception {
  static const _unknown = 'UNKNOWN';

  final String code;
  final String message;
  final Map<String, dynamic> details;

  const ApiException(this.code, this.message, this.details);
  const ApiException.unknown(this.message)
      : code = ApiException._unknown,
        details = const {};
  factory ApiException.fromPlatformException(final PlatformException e) =>
      ApiException(
          e.code,
          e.message ?? '', // Errors from native should always have a message
          Map<String, dynamic>.from(
              (e.details ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>));

  @override
  String toString() => '$code: $message';

  bool get isMultifactorRequired => details['isMultifactorRequired'] as bool;
  bool get isMultifactorEnrollRequired => details['isMultifactorEnrollRequired'] as bool;
  bool get isMultifactorCodeInvalid => details['isMultifactorCodeInvalid'] as bool;
  bool get isMultifactorTokenInvalid => details['isMultifactorTokenInvalid'] as bool;
  bool get isPasswordNotStrongEnough => details['isPasswordNotStrongEnough'] as bool;
  bool get isPasswordAlreadyUsed => details['isPasswordAlreadyUsed'] as bool;
  bool get isRuleError => details['isRuleError'] as bool;
  bool get isInvalidCredentials => details['isInvalidCredentials'] as bool;
  bool get isRefreshTokenDeleted => details['isRefreshTokenDeleted'] as bool;
  bool get isAccessDenied => details['isAccessDenied'] as bool;
  bool get isTooManyAttempts => details['isTooManyAttempts'] as bool;
  bool get isVerificationRequired => details['isVerificationRequired'] as bool;
  bool get isNetworkError => details['isNetworkError'] as bool;
  bool? get isBrowserAppNotAvailable => details['isBrowserAppNotAvailable'] as bool?;
  bool get isPKCENotAvailable => details['isPKCENotAvailable'] as bool;
  bool get isInvalidAuthorizeURL => details['isInvalidAuthorizeURL'] as bool;
  bool get isInvalidConfiguration => details['isInvalidConfiguration'] as bool;
  bool get isCanceled => details['isCanceled'] as bool;
  bool get isPasswordLeaked => details['isPasswordLeaked'] as bool;
  bool get isLoginRequired => details['isLoginRequired'] as bool;

}
