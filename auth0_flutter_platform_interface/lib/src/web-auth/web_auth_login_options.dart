import '../id_token_validation_config.dart';
import '../login_options.dart';

class WebAuthLoginOptions extends LoginOptions {
  final bool useEphemeralSession;
  final String? scheme;

  WebAuthLoginOptions(
      {final IdTokenValidationConfig? idTokenValidationConfig,
      final String? audience,
      final Set<String>? scopes,
      final String? redirectUrl,
      final String? organizationId,
      final String? invitationUrl,
      this.scheme,
      this.useEphemeralSession = false,
      final Map<String, String>? parameters})
      : super(
            idTokenValidationConfig: idTokenValidationConfig,
            audience: audience,
            scopes: scopes ?? {},
            redirectUrl: redirectUrl,
            organizationId: organizationId,
            invitationUrl: invitationUrl,
            parameters: parameters ?? {});

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'useEphemeralSession': useEphemeralSession,
        'scheme': scheme,
      };
}
