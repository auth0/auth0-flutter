class WebAuthException implements Exception {
  static const _unknown = 'unknown';

  final String code;
  final String message;

  const WebAuthException(this.code, this.message);
  const WebAuthException.unknown(this.message)
      : code = WebAuthException._unknown;
  factory WebAuthException.fromMap(final Map<String, String> map) =>
      WebAuthException(map['code'] as String, map['message'] as String);

  @override
  String toString() => '$code: $message';
}
