class ExchangeTokenOptions {
  final String subjectToken;
  final String subjectTokenType;
  final String? audience;
  final Set<String> scopes;
  final String? organizationId;
  final Map<String, String> parameters;

  ExchangeTokenOptions({
    required this.subjectToken,
    required this.subjectTokenType,
    this.audience,
    this.scopes = const {},
    this.organizationId,
    this.parameters = const {},
  });
}
