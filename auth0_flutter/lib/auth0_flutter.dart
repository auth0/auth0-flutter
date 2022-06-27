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
        CredentialsManagerException;

export 'src/credentials_manager.dart';

class Auth0Options {
  late bool useCredentialsManager;
}

class Auth0 {
  final Account _account;
  final UserAgent _userAgent =
      UserAgent(name: 'auth0-flutter', version: version);

  late CredentialsManager? _credentialsManager;

  /// Uses the [DefaultCredentialsManager] by default. If you want to use your own implementation to handle credential storage, provide your own [CredentialsManager] implementation
  /// by setting [customCredentialsManager].
  /// In case you want to opt-out of using any [CredentialsManager] alltogether, set [useCredentialsManager] to `false`.
  /// If you want to use biometrics when using the [DefaultCredentialsManager], set [useBiometrics]` to `true`.
  /// Note however that this settings has no effect when specifying a [customCredentialsManager]
  Auth0(
    final String domain,
    final String clientId, {
    final bool useCredentialsManager = true,
    final bool useBiometrics = false,
    final CredentialsManager? customCredentialsManager,
  }) : _account = Account(domain, clientId) {
    _credentialsManager = useCredentialsManager
        ? (customCredentialsManager ??
            (DefaultCredentialsManager(_account, _userAgent,
                useBiometrics: useBiometrics)))
        : null;
  }

  AuthenticationApi get api => AuthenticationApi(_account, _userAgent);

  /// Creates an instance of [WebAuthentication].
  ///
  /// In order to not use any [CredentialsManager], opt-out by setting [useCredentialsManager] to false.
  WebAuthentication webAuthentication({
    final bool useCredentialsManager = true,
  }) =>
      WebAuthentication(_account, _userAgent,
          useCredentialsManager ? _credentialsManager : null);

  /// Returns the already created [CredentialsManager] if [webAuthentication] was called. If not, creates and returns an instance of [DefaultCredentialsManager].
  CredentialsManager? credentialsManager() => _credentialsManager;
}
