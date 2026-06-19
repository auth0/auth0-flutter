import 'package:flutter/services.dart';

import '../auth0_exception.dart';
import '../extensions/exception_extensions.dart';
import '../extensions/map_extensions.dart';

/// An error raised by an MFA operation (`getAuthenticators`, `enroll*`,
/// `challenge`, `verify`).
class MfaException extends Auth0Exception {
  static const _statusCodeKey = '_statusCode';
  static const _errorFlagsKey = '_errorFlags';

  final int statusCode;
  final Map<dynamic, dynamic> _errorFlags;

  const MfaException(final String code, final String message,
      final Map<String, dynamic> details, this._errorFlags, this.statusCode)
      : super(code, message, details);

  const MfaException.unknown(final String message)
      : _errorFlags = const {},
        statusCode = 0,
        super.unknown(message); // coverage:ignore-line

  factory MfaException.fromPlatformException(final PlatformException e) {
    final Map<String, dynamic> errorDetails = e.detailsMap;
    final statusCode = errorDetails.getOrDefault(_statusCodeKey, 0);
    final errorFlags =
        errorDetails.getOrDefault(_errorFlagsKey, <dynamic, dynamic>{});

    errorDetails.remove(_statusCodeKey);
    errorDetails.remove(_errorFlagsKey);

    return MfaException(
        e.code, e.messageString, errorDetails, errorFlags, statusCode);
  }

  /// Whether the `mfa_token` has expired (default expiry is 10 minutes). The
  /// user must restart the original authentication request to obtain a new
  /// token.
  bool get isMfaTokenExpired => code == 'expired_token';

  /// Whether the request was malformed, e.g. an invalid challenge type or a
  /// verification with an authenticator not allowed by the `mfa_token`.
  bool get isInvalidRequest => code == 'invalid_request';

  /// Whether the one-time / out-of-band code provided to `verify` was invalid.
  bool get isInvalidCode =>
      code == 'invalid_grant' || code == 'invalid_otp_code';

  bool get isNetworkError => _errorFlags.getBooleanOrFalse('isNetworkError');
  bool get isRetryable => isNetworkError;
}
