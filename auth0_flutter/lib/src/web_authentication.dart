import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class WebAuthentication {
  final Account account;

  WebAuthentication(this.account);

  Future<LoginResult> login(
          {final String? audience,
          final Set<String> scopes = const {},
          final String? redirectUri,
          final String? organizationId,
          final String? invitationUrl,
          final bool useEphemeralSession = false,
          final Map<String, String> parameters = const {},
          final IdTokenValidationConfig idTokenValidationConfig =
              const IdTokenValidationConfig()}) =>
      Auth0FlutterWebAuthPlatform.instance.login(WebAuthLoginOptions(
          audience: audience,
          scopes: scopes,
          redirectUri: redirectUri,
          organizationId: organizationId,
          invitationUrl: invitationUrl,
          parameters: parameters,
          account: account,
          idTokenValidationConfig: idTokenValidationConfig));

  Future<void> logout({final String? returnTo}) =>
      Auth0FlutterWebAuthPlatform.instance.logout(WebAuthLogoutOptions(
        returnTo: returnTo,
        account: account,
      ));
}
