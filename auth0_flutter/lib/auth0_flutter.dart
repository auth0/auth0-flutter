import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import 'src/mobile/authentication_api.dart';
import 'src/mobile/credentials_manager.dart';
import 'src/mobile/web_authentication.dart';
import 'src/version.dart';

export 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show
        WebAuthenticationException,
        ApiException,
        IdTokenValidationConfig,
        SafariViewController,
        SafariViewControllerPresentationStyle,
        Credentials,
        UserProfile,
        DatabaseUser,
        ChallengeType,
        CredentialsManagerException,
        PasswordlessType,
        LocalAuthentication;

export 'src/mobile/authentication_api.dart';
export 'src/mobile/credentials_manager.dart';
export 'src/mobile/web_authentication.dart';

/// Primary interface for interacting with Auth0 using web authentication,
/// or the authentication API.
class Auth0 {
  final Account _account;

  final UserAgent _userAgent =
      UserAgent(name: 'auth0-flutter', version: version);

  late final CredentialsManager _credentialsManager;

  /// Secure [Credentials] store.
  CredentialsManager get credentialsManager => _credentialsManager;

  /// Creates an intance of an Auth0 client with the provided [domain] and
  /// [clientId] properties.
  ///
  /// [domain] and [clientId] are both values that can be retrieved from the application in your [Auth0 Dashboard](https://manage.auth0.com).
  /// If you want to use your own implementation to handle credential storage,
  /// provide your own [CredentialsManager] implementation by setting
  /// [credentialsManager]. A [DefaultCredentialsManager] instance is used by
  /// default.
  /// If you want to use biometrics or pass-phrase when using the
  /// [DefaultCredentialsManager], set [localAuthentication]` to an instance
  /// of [LocalAuthentication]. Note however that this setting has no effect
  /// when specifying a custom [credentialsManager].
  /// Use [CredentialsManagerConfiguration] to set platform-specific
  /// configuration for the default CredentialsManager.
  Auth0(final String domain, final String clientId,
      {final LocalAuthentication? localAuthentication,
      final CredentialsManager? credentialsManager,
      final CredentialsManagerConfiguration? credentialsManagerConfiguration})
      : _account = Account(domain, clientId) {
    _credentialsManager = credentialsManager ??
        DefaultCredentialsManager(
          _account,
          _userAgent,
          localAuthentication: localAuthentication,
          credentialsManagerConfiguration:credentialsManagerConfiguration
        );
  }


  /// An instance of [AuthenticationApi], the primary interface for interacting
  /// with the Auth0 Authentication API
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
  /// By default, the credentials will be stored in the [CredentialsManager].
  /// In case you want to opt-out of using the [CredentialsManager], set
  /// [useCredentialsManager] to `false`. (Android only): specify [scheme] if
  /// you're using a custom URL scheme for your app. This value must match the
  /// value used to configure the `auth0Scheme` manifest placeholder, for the
  /// Redirect intent filter to work.
  WebAuthentication webAuthentication(
          {final String? scheme, final bool useCredentialsManager = true}) =>
      WebAuthentication(_account, _userAgent, scheme,
          useCredentialsManager ? credentialsManager : null);
}
