import '../../auth0_flutter_platform_interface.dart';

/// Exception thrown by [Auth0FlutterWebPlatform] when something
/// goes wrong.
class WebException extends Auth0Exception {
  static const String _mfaRequired = 'MFA_REQUIRED';

  const WebException(final String error, final String errorDescription,
      final Map<String, dynamic> details)
      : super(error, errorDescription, details);

  WebException.mfaError(final String message, final String mfaToken)
      : this(WebException._mfaRequired, message, {'mfaToken': mfaToken});
}
