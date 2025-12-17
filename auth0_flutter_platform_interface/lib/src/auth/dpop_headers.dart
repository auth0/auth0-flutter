class DPoPHeaders {
  final String authorization;
  final String dpop;

  const DPoPHeaders({
    required this.authorization,
    required this.dpop,
  });

  factory DPoPHeaders.fromMap(final Map<String, dynamic> map) => DPoPHeaders(
        authorization: map['authorization'] as String,
        dpop: map['dpop'] as String,
      );
}
