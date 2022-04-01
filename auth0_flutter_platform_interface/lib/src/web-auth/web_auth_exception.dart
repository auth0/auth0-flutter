import 'package:flutter/services.dart';

class WebAuthException implements Exception {
  static const _unknown = 'UNKNOWN';

  final String code;
  final String message;
  final Map<String, dynamic> details;

  const WebAuthException(this.code, this.message, this.details);
  const WebAuthException.unknown(this.message)
      : code = WebAuthException._unknown,
        details = const {};
  factory WebAuthException.fromPlatformException(final PlatformException e) =>
      WebAuthException(
          e.code,
          e.message ?? '', // Errors from native should always have a message
          Map<String, dynamic>.from(
              (e.details ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>));

  @override
  String toString() => '$code: $message';
}
