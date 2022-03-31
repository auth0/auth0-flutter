import '../account.dart';

class IdTokenValidationConfig {
  final int? leeway;
  final String? issuer;
  final int? maxAge;

  const IdTokenValidationConfig({this.leeway, this.issuer, this.maxAge});
}

class WebAuthLoginOptions {
  final Account account;
  final IdTokenValidationConfig? idTokenValidationConfig;
  final String? audience;
  final Set<String> scopes;
  final String? redirectUri;
  final String? organizationId;
  final String? invitationUrl;
  final bool useEphemeralSession;
  final Map<String, String> parameters;

  WebAuthLoginOptions(
      {required this.account,
      this.idTokenValidationConfig,
      this.audience,
      required this.scopes,
      this.redirectUri,
      this.organizationId,
      this.invitationUrl,
      this.useEphemeralSession = false,
      this.parameters = const {}});
  
  Map<String, dynamic> toMap() => {
        'domain': account.domain,
        'clientId': account.clientId,
        'leeway': idTokenValidationConfig?.leeway,
        'issuer': idTokenValidationConfig?.issuer,
        'maxAge': idTokenValidationConfig?.maxAge,
        'audience': audience,
        'scopes': scopes.toList(),
        'redirectUri': redirectUri,
        'organizationId': organizationId,
        'invitationUrl': invitationUrl,
        'useEphemeralSession': useEphemeralSession,
        'parameters': parameters
      };
}
