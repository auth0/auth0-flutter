import 'package:flutter/services.dart';

import '../auth0_exception.dart';
import '../extensions/exception_extensions.dart';

// ignore: comment_references
/// Exception thrown by [MethodChannelCredentialsManager] when something goes
/// wrong.
class CredentialsManagerException extends Auth0Exception {
  const CredentialsManagerException(final String code, final String message,
      final Map<String, dynamic> details)
      : super(code, message, details);

  const CredentialsManagerException.unknown(final String message)
      : super.unknown(message); // coverage:ignore-line

  /// Fectory method that transforms a [PlatformException] to a
  /// [CredentialsManagerException].
  factory CredentialsManagerException.fromPlatformException(
      final PlatformException e) {
    final Map<String, dynamic> errorDetails = e.detailsMap;

    return CredentialsManagerException(e.code, e.messageString, errorDetails);
  }

  bool get isTokenRenewFailed =>
      code == 'RENEW_FAILED' ||
      code ==
          '''
An error occurred while trying to use the Refresh Token to renew the Credentials.''';

  bool get isNoCredentialsFound =>
      code == 'NO_CREDENTIALS' || code == 'No Credentials were previously set.';

  bool get isNoRefreshTokenFound =>
      code == 'NO_REFRESH_TOKEN' ||
      code ==
          '''
Credentials need to be renewed but no Refresh Token is available to renew them.''';
}
