class WebAuthLoginOptions {
  late String audience;
  late String scopes;
  late String redirectUri;
  late String idTokenValidationConfig;
  late String organizationId;
  late String useEphemeralSession;
  late String parameters;

  WebAuthLoginOptions(
      this.audience,
      this.scopes,
      this.redirectUri,
      this.idTokenValidationConfig,
      this.organizationId,
      this.useEphemeralSession,
      this.parameters);
}
