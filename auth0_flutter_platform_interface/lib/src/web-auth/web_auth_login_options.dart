class IdTokenValidationConfig {
  final int? leeway;
  final String? issuer;
  final int? maxAge;

  const IdTokenValidationConfig({this.leeway, this.issuer, this.maxAge});
}

class WebAuthLoginOptions {
  final String? audience;
  final Set<String> scopes;
  final String? redirectUri;
  final IdTokenValidationConfig? idTokenValidationConfig;
  final String? organizationId;
  final bool useEphemeralSession;
  final Map<String, String> parameters;

  WebAuthLoginOptions(
      {this.audience,
      required this.scopes,
      this.redirectUri,
      this.idTokenValidationConfig,
      this.organizationId,
      this.useEphemeralSession = false,
      this.parameters = const {}});
}
