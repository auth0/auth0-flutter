import 'id_token_validation_config.dart';
import 'request/request_options.dart';

class LoginOptions implements RequestOptions {
  final IdTokenValidationConfig? idTokenValidationConfig;
  final Object? appState;
  final String? audience;
  final Set<String> scopes;
  final String? redirectUrl;
  final String? organizationId;
  final String? invitationUrl;
  final Future<void> Function(String url)? openUrl;
  final Map<String, String> parameters;

  LoginOptions({
    this.idTokenValidationConfig,
    this.appState,
    this.audience,
    this.scopes = const {},
    this.redirectUrl,
    this.organizationId,
    this.invitationUrl,
    this.openUrl,
    this.parameters = const {},
  });

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
    'openUrl': openUrl,
    'parameters': parameters,
  };
}
