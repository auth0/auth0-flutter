import 'dart:ffi';

class IdTokenValidationConfig {}

class WebAuthLoginOptions {
  late String audience;
  late Set<String> scopes;
  late String redirectUri;
  late IdTokenValidationConfig? idTokenValidationConfig;
  late String? organizationId;
  late bool? useEphemeralSession;
  late Map<String, String>? parameters;

  WebAuthLoginOptions(
      {required final String audience,
      required final Set<String> scopes,
      required final String redirectUri,
      final IdTokenValidationConfig? idTokenValidationConfig,
      final String? organizationId,
      final bool? useEphemeralSession,
      final Map<String, String>? parameters}) {
    this.audience = audience;
    this.scopes = scopes;
    this.redirectUri = redirectUri;
    this.idTokenValidationConfig = idTokenValidationConfig;
    this.organizationId = organizationId;
    this.useEphemeralSession = useEphemeralSession;
    this.parameters = parameters;
  }
}
