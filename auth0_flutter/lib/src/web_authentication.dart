import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../auth0_flutter.dart';

class WebAuthentication {
  final Account _account;
  final UserAgent _userAgent;
  final CredentialsManager? _credentialsManager;

  CredentialsManager? credentialsManager() => _credentialsManager;

  WebAuthentication(this._account, this._userAgent, this._credentialsManager);

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
  }) async {
    final credentials = await Auth0FlutterWebAuthPlatform.instance.login(
        _createWebAuthRequest(WebAuthLoginOptions(
            audience: audience,
            scopes: scopes,
            redirectUrl: redirectUrl,
            organizationId: organizationId,
            invitationUrl: invitationUrl,
            parameters: parameters,
            idTokenValidationConfig: idTokenValidationConfig,
            scheme: scheme,
            useEphemeralSession: useEphemeralSession)));

    await _credentialsManager?.set(credentials);

    return credentials;
  }

  Future<void> logout({final String? returnTo, final String? scheme}) async {
    await Auth0FlutterWebAuthPlatform.instance.logout(_createWebAuthRequest(
      WebAuthLogoutOptions(returnTo: returnTo, scheme: scheme),
    ));
    await _credentialsManager?.clear();
  }

  /// Retrieves the Credentials for the current user. Calls the [CredentialsManager] when available, returns `null` if not.
  ///
  /// Change the minimum time in seconds that the access token should last before expiration by setting the [minTtl].
  /// Use the [scopes] parameter to set the scope to request for the access token. If `null` is passed, the previous scope will be kept.
  /// Use the [parameters] parameter to send additional parameters in the request to refresh expired credentials.
  Future<Credentials?> credentials({
    final int minTtl = 0,
    final Set<String> scopes = const {},
    final Map<String, String> parameters = const {},
  }) async {
    final credentials = await _credentialsManager?.get(
      minTtl: minTtl,
      scopes: scopes,
      parameters: parameters,
    );

    return credentials;
  }

  WebAuthRequest<TOptions>
      _createWebAuthRequest<TOptions extends RequestOptions>(
              final TOptions options) =>
          WebAuthRequest<TOptions>(
              account: _account, options: options, userAgent: _userAgent);
}
