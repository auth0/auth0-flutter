import '../../auth0_flutter_platform_interface.dart';

/// Exception thrown by [Auth0FlutterWebPlatform] when something
/// goes wrong.
class WebException extends Auth0Exception {
  static const String _mfaRequired = 'MFA_REQUIRED';
  static const String _timeout = 'TIMEOUT';
  static const String _missingRefreshToken = 'MISSING_REFRESH_TOKEN';
  static const String _popupClosed = 'POPUP_CLOSED';
  static const String _authenticationError = 'AUTHENTICATION_ERROR';
  static const String _passkeyError = 'PASSKEY_ERROR';

  const WebException(final String error, final String errorDescription,
      final Map<String, dynamic> details)
      : super(error, errorDescription, details);

  WebException.authenticationError(final String error, final String message,
      [final Map<String, dynamic>? details])
      : this(WebException._authenticationError, message,
            {'code': error, ...details ?? {}});

  /// A passkey-related operation (challenge request or credential exchange)
  /// failed. [error] carries the underlying `auth0-spa-js` passkey error
  /// code (for example `passkey_register_error`, `passkey_not_supported`).
  WebException.passkeyError(final String error, final String message,
      [final Map<String, dynamic>? details])
      : this(WebException._passkeyError, message,
            {'code': error, ...details ?? {}});

  WebException.mfaError(final String message, final String mfaToken)
      : this(WebException._mfaRequired, message, {'mfaToken': mfaToken});

  WebException.timeout(final String message)
      : this(WebException._timeout, message, const {});

  WebException.missingRefreshToken(final String message)
      : this(WebException._missingRefreshToken, message, const {});

  WebException.popupClosed(final String message)
      : this(WebException._popupClosed, message, const {});
}
