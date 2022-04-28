import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import 'src/authentication_api.dart';
import 'src/version.dart';
import 'src/web_authentication.dart';

export 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show WebAuthException, ApiException, IdTokenValidationConfig;

class Auth0 {
  final Account _account;
  final UserAgent _userAgent =
      UserAgent(name: 'auth0-flutter', version: version);

  Auth0(final String domain, final String clientId)
      : _account = Account(domain, clientId);

  WebAuthentication get webAuthentication =>
      WebAuthentication(_account, _userAgent);

  AuthenticationApi get api => AuthenticationApi(_account, _userAgent);
}
