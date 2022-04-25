import '../request/request_options.dart';

class IdTokenValidationConfig {
  final int? leeway;
  final String? issuer;
  final int? maxAge;

  const IdTokenValidationConfig({this.leeway, this.issuer, this.maxAge});
}

class WebAuthLoginInput implements RequestOptions {
  final IdTokenValidationConfig? idTokenValidationConfig;
  final String? audience;
  final Set<String> scopes;
  final String? redirectUri;
  final String? organizationId;
  final String? invitationUrl;
  final bool useEphemeralSession;
  final Map<String, String> parameters;
  final String? scheme;

  WebAuthLoginInput({
      this.idTokenValidationConfig,
      this.audience,
      this.scopes = const {},
      this.redirectUri,
      this.organizationId,
      this.invitationUrl,
      this.scheme,
      this.useEphemeralSession = false,
      this.parameters = const {}});

  @override
  Map<String, dynamic> toMap() => {
        'leeway': idTokenValidationConfig?.leeway,
        'issuer': idTokenValidationConfig?.issuer,
        'maxAge': idTokenValidationConfig?.maxAge,
        'audience': audience,
        'scopes': scopes.toList(),
        'redirectUri': redirectUri,
        'organizationId': organizationId,
        'invitationUrl': invitationUrl,
        'useEphemeralSession': useEphemeralSession,
        'parameters': parameters,
        'scheme': scheme
      };
}
