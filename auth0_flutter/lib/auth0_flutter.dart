import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import 'src/authentication_api.dart';
import 'src/credentials_manager.dart';
import 'src/version.dart';
import 'src/web_authentication.dart';

export 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show
        WebAuthException,
        ApiException,
        IdTokenValidationConfig,
        Credentials,
        CredentialsManagerException,
        LocalAuthenticationOptions;

export 'src/credentials_manager.dart';
export 'src/web_authentication.dart';

class Auth0 {
  final Account _account;
  final UserAgent _userAgent =
      UserAgent(name: 'auth0-flutter', version: version);

  Auth0(final String domain, final String clientId)
      : _account = Account(domain, clientId);

  AuthenticationApi get api => AuthenticationApi(_account, _userAgent);

  /// Creates an instance of [WebAuthentication].
  ///
  /// Uses the [DefaultCredentialsManager] by default. If you want to use your own implementation to handle credential storage, provide your own [CredentialsManager] implementation
  /// by setting [customCredentialsManager].
  /// In case you want to opt-out of using any [CredentialsManager] alltogether, set [useCredentialsManager] to `false`.
  /// If you want to use biometrics or pass-phrase when using the [DefaultCredentialsManager], set [useLocalAuthentication]` to `true`.
  /// Note however that this settings has no effect when specifying a [customCredentialsManager]
  WebAuthentication webAuthentication({
    final bool useCredentialsManager = true,
    final LocalAuthenticationOptions? localAuthentication,
    final CredentialsManager? customCredentialsManager,
  }) {
    final credentialsManager = useCredentialsManager
        ? (customCredentialsManager ??
            (DefaultCredentialsManager(
              _account,
              _userAgent,
              localAuthentication: localAuthentication,
            )))
        : null;
    return WebAuthentication(_account, _userAgent, credentialsManager);
  }
}
