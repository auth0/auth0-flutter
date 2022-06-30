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
        UserProfile,
        CredentialsManagerException,
        LocalAuthenticationOptions;

export 'src/authentication_api.dart';
export 'src/credentials_manager.dart';
export 'src/web_authentication.dart';

/// Primary interface for interacting with Auth0 using web authentication, or the authentication API.
class Auth0 {
  final Account _account;

  final UserAgent _userAgent =
      UserAgent(name: 'auth0-flutter', version: version);

  /// Creates an intance of an Auth0 client with the provided [domain] and [clientId] properties.
  ///
  /// [domain] and [clientId] are both values that can be retrieved from the application in your [Auth0 Dashboard](https://manage.auth0.com).
  Auth0(final String domain, final String clientId)
      : _account = Account(domain, clientId);

  /// An instance of [AuthenticationApi], the primary interface for interacting with the Auth0 Authentication API
  ///
  /// Usage example:
  ///
  /// ```dart
  /// final auth0 = Auth0('DOMAIN', 'CLIENT_ID');
  ///
  /// final result = await auth0.api.login({
  ///   usernameOrEmail: 'my@email.com',
  ///   password: 'my_password'
  ///   connectionOrRealm: 'Username-Password-Authentication'
  /// });
  ///
  /// final accessToken = result.accessToken;
  /// ```

  AuthenticationApi get api => AuthenticationApi(_account, _userAgent);

  /// Creates an instance of [WebAuthentication], the primary interface for interacting with the [Auth0 Universal Login page](https://auth0.com/docs/authenticate/login/auth0-universal-login).
  ///
  /// Usage example:
  ///
  /// ```dart
  /// final auth0 = Auth0('DOMAIN', 'CLIENT_ID');
  /// final result = await auth0.webAuthentication().login();
  /// final accessToken = result.accessToken;
  /// ```
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
