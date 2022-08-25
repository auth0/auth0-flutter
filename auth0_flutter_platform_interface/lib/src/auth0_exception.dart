abstract class Auth0Exception implements Exception {
  static const _unknownError = 'UNKNOWN';

  final String code;
  final String message;
  final Map<String, dynamic> details;

  const Auth0Exception(this.code, this.message, this.details);

  const Auth0Exception.unknown(final String message)
      : this(Auth0Exception._unknownError, message, const {});

  @override
  String toString() => '$code: $message';
}
