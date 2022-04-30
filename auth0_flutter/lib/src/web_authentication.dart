import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class WebAuthentication {
  final Account _account;
  final UserAgent _userAgent;

  WebAuthentication(this._account, this._userAgent);

  Future<Credentials> login({
    final String? audience,
    final Set<String> scopes = const {},
    final String? redirectUrl,
    final String? organizationId,
    final String? invitationUrl,
    final String? scheme,
    final bool useEphemeralSession = false,
    final Map<String, String> parameters = const {},
    final IdTokenValidationConfig idTokenValidationConfig =
        const IdTokenValidationConfig(),
  }) =>
      Auth0FlutterWebAuthPlatform.instance.login(createWebAuthRequest(
          WebAuthLoginOptions(
              audience: audience,
              scopes: scopes,
              redirectUrl: redirectUrl,
              organizationId: organizationId,
              invitationUrl: invitationUrl,
              parameters: parameters,
              idTokenValidationConfig: idTokenValidationConfig,
              scheme: scheme,
              useEphemeralSession: useEphemeralSession)));

  Future<void> logout({final String? returnTo, final String? scheme}) =>
      Auth0FlutterWebAuthPlatform.instance.logout(createWebAuthRequest(
        WebAuthLogoutOptions(returnTo: returnTo, scheme: scheme),
      ));

  WebAuthRequest<TOptions>
      createWebAuthRequest<TOptions extends RequestOptions>(
              final TOptions options) =>
          WebAuthRequest<TOptions>(
              account: _account, options: options, userAgent: _userAgent);
}
