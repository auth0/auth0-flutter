import 'package:flutter/services.dart';

class AuthException implements Exception {
  static const _unknown = 'UNKNOWN';

  final String code;
  final String message;
  final Map<String, dynamic> details;

  const AuthException(this.code, this.message, this.details);
  const AuthException.unknown(this.message)
      : code = AuthException._unknown,
        details = const {};
  factory AuthException.fromPlatformException(final PlatformException e) =>
      AuthException(
          e.code,
          e.message ?? '', // Errors from native should always have a message
          Map<String, dynamic>.from(
              (e.details ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>));

  @override
  String toString() => '$code: $message';
}
