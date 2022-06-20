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

  CredentialsManager credentialsManager() => _credentialsManager ??= DefaultCredentialsManager(_account, _userAgent);
}
