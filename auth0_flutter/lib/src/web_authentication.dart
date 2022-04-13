import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class WebAuthentication {
  final Account account;

  WebAuthentication(this.account);

  Future<Credentials> login(
          {final String? audience,
          final Set<String> scopes = const {},
          final String? redirectUri,
          final String? organizationId,
          final String? invitationUrl,
          final String? scheme,
          final bool useEphemeralSession = false,
          final Map<String, String> parameters = const {},
          final IdTokenValidationConfig idTokenValidationConfig =
              const IdTokenValidationConfig()}) =>
      Auth0FlutterWebAuthPlatform.instance.login(WebAuthLoginInput(
          audience: audience,
          scopes: scopes,
          redirectUri: redirectUri,
          organizationId: organizationId,
          invitationUrl: invitationUrl,
          parameters: parameters,
          account: account,
          idTokenValidationConfig: idTokenValidationConfig,
          scheme: scheme,
          useEphemeralSession: useEphemeralSession));

  Future<void> logout({final String? returnTo, final String? scheme}) =>
      Auth0FlutterWebAuthPlatform.instance.logout(WebAuthLogoutInput(
          returnTo: returnTo, account: account, scheme: scheme));
}
