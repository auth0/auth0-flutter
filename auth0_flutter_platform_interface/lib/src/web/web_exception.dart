import '../../auth0_flutter_platform_interface.dart';

/// Exception thrown by [Auth0FlutterWebPlatform] when something
/// goes wrong.
class WebException extends Auth0Exception {
  const WebException(final String error, final String errorDescription,
      final Map<String, dynamic> details)
      : super(error, errorDescription, details);
}
