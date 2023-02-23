import 'id_token_validation_config.dart';
import 'request/request_options.dart';

class LoginOptions implements RequestOptions {
  final IdTokenValidationConfig? idTokenValidationConfig;
  final String? audience;
  final Set<String> scopes;
  final String? redirectUrl;
  final String? organizationId;
  final String? invitationUrl;
  final Map<String, String> parameters;

  LoginOptions(
      {this.idTokenValidationConfig,
      this.audience,
      this.scopes = const {},
      this.redirectUrl,
      this.organizationId,
      this.invitationUrl,
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
        'parameters': parameters,
      };
}
