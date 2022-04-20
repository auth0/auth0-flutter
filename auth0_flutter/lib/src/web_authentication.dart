import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class WebAuthentication {
  final Account account;
  final Telemetry telemetry;

  WebAuthentication(this.account, this.telemetry);

  Future<Credentials> login({
    final String? audience,
    final Set<String> scopes = const {},
    final String? redirectUri,
    final String? organizationId,
    final String? invitationUrl,
    final String? scheme,
    final bool useEphemeralSession = false,
    final Map<String, String> parameters = const {},
    final IdTokenValidationConfig idTokenValidationConfig =
        const IdTokenValidationConfig(),
  }) =>
      Auth0FlutterWebAuthPlatform.instance.login(createWebAuthRequest(
          WebAuthLoginInput(
              audience: audience,
              scopes: scopes,
              redirectUri: redirectUri,
              organizationId: organizationId,
              invitationUrl: invitationUrl,
              parameters: parameters,
              idTokenValidationConfig: idTokenValidationConfig,
              scheme: scheme,
              useEphemeralSession: useEphemeralSession,
              telemetry: telemetry)));

  Future<void> logout({final String? returnTo, final String? scheme}) =>
      Auth0FlutterWebAuthPlatform.instance.logout(createWebAuthRequest(
        WebAuthLogoutInput(
            returnTo: returnTo, scheme: scheme, telemetry: telemetry),
      ));

  WebAuthRequest<TOptions>
      createWebAuthRequest<TOptions extends RequestOptions>(
              final TOptions options) =>
          WebAuthRequest<TOptions>(account: account, options: options);
}
