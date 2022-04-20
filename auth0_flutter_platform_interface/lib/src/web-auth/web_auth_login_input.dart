import '../request/request_options.dart';
import '../telemetry.dart';

class IdTokenValidationConfig {
  final int? leeway;
  final String? issuer;
  final int? maxAge;

  const IdTokenValidationConfig({this.leeway, this.issuer, this.maxAge});
}

class WebAuthLoginInput implements RequestOptions {
  final Telemetry telemetry;
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
      required this.telemetry,
      this.idTokenValidationConfig,
      this.audience,
      required this.scopes,
      this.redirectUri,
      this.organizationId,
      this.invitationUrl,
      this.scheme,
      this.useEphemeralSession = false,
      this.parameters = const {}});

  @override
  Map<String, dynamic> toMap() => {
        'telemetry': telemetry.toMap(),
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
