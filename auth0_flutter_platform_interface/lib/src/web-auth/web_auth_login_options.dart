import '../request/request_options.dart';
import 'id_token_validation_config.dart';

class WebAuthLoginOptions implements RequestOptions {
  final IdTokenValidationConfig? idTokenValidationConfig;
  final String? audience;
  final Set<String> scopes;
  final String? redirectUrl;
  final String? organizationId;
  final String? invitationUrl;
  final bool useEphemeralSession;
  final Map<String, String> parameters;
  final String? scheme;

  WebAuthLoginOptions(
      {this.idTokenValidationConfig,
      this.audience,
      this.scopes = const {},
      this.redirectUrl,
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
        'redirectUrl': redirectUrl,
        'organizationId': organizationId,
        'invitationUrl': invitationUrl,
        'useEphemeralSession': useEphemeralSession,
        'parameters': parameters,
        'scheme': scheme
      };
}
