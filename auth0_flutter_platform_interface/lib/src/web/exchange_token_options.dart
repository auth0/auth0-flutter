class ExchangeTokenOptions {
  final String subjectToken;
  final String subjectTokenType;
  final String? audience;
  final Set<String>? scopes;
  final String? organizationId;

  ExchangeTokenOptions({
    required this.subjectToken,
    required this.subjectTokenType,
    this.audience,
    this.scopes,
    this.organizationId,
  });
}
