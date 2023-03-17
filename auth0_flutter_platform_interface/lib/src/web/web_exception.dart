import '../../auth0_flutter_platform_interface.dart';

class WebException extends Auth0Exception {
  const WebException(final String error, final String errorDescription,
      final Map<String, dynamic> details)
      : super(error, errorDescription, details);
}
