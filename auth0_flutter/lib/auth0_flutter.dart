import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import 'src/authentication_api.dart';
import 'src/version.dart';
import 'src/web_authentication.dart';

export 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show
        WebAuthException,
        ApiException,
        IdTokenValidationConfig,
        Credentials,
        UserProfile;

export 'src/authentication_api.dart';
export 'src/web_authentication.dart';

/// Primary interface for interacting with Auth0 using web authentication, or the authentication API.
class Auth0 {
  final Account _account;

  final UserAgent _userAgent =
      UserAgent(name: 'auth0-flutter', version: version);

  /// Creates an intance of an Auth0 client with the provided `domain` and `clientId` properties.
  ///
  /// `domain` and `clientId` are both values that can be retrieved from the application in your [Auth0 Dashboard](https://manage.auth0.com).
  Auth0(final String domain, final String clientId)
      : _account = Account(domain, clientId);

  /// An instance of [WebAuthentication], the primary interface for interacting with the [Auth0 Universal Login page](https://auth0.com/docs/authenticate/login/auth0-universal-login).
  ///
  /// Usage example:
  ///
  /// ```dart
  /// final auth0 = Auth0('DOMAIN', 'CLIENT_ID');
  /// final result = await auth0.webAuthentication.login();
  /// final idToken = result.idToken;
  /// ```
  WebAuthentication get webAuthentication =>
      WebAuthentication(_account, _userAgent);

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
  /// final idToken = result.idToken;
  /// ```
  AuthenticationApi get api => AuthenticationApi(_account, _userAgent);
}
