import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import 'src/authentication_api.dart';
import 'src/credentials_manager.dart';
import 'src/version.dart';
import 'src/web_authentication.dart';

export 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show WebAuthException, ApiException, IdTokenValidationConfig, Credentials, CredentialsManagerException;

export 'src/credentials_manager.dart';

class Auth0 {
  final Account _account;
  final UserAgent _userAgent =
      UserAgent(name: 'auth0-flutter', version: version);

  CredentialsManager? _credentialsManager;

  Auth0(final String domain, final String clientId)
      : _account = Account(domain, clientId);

  AuthenticationApi get api => AuthenticationApi(_account, _userAgent);

  /// Creates an instance of [WebAuthentication].
  ///
  /// Uses the [DefaultCredentialsManager] by default. If you want to use your own implementation to handle credenial storage, provide your own [CredentialsManager] implementation
  /// by setting [customCredentialsManager].
  ///
  /// In order to not use any [CredentialsManager] at all, opt-out by setting [useCredentialsManager] to false.
  WebAuthentication webAuthentication({
    final bool useCredentialsManager = true,
    final CredentialsManager? customCredentialsManager,
  }) {
    CredentialsManager? cm;
    if (useCredentialsManager) {
      cm = customCredentialsManager ?? credentialsManager();
    }

    _credentialsManager = cm;

    return WebAuthentication(_account, _userAgent, cm);
  }

  /// Returns the already created [CredentialsManager] if [webAuthentication] was called. If not, creates and returns an instance of [DefaultCredentialsManager].
  CredentialsManager credentialsManager() => _credentialsManager ??= DefaultCredentialsManager(_account, _userAgent);
}
