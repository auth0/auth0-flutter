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
}
