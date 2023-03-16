class WebException implements Exception {
  final String error;
  final String errorDescription;

  const WebException(this.error, this.errorDescription);

  @override
  String toString() => '$error: $errorDescription';
}
