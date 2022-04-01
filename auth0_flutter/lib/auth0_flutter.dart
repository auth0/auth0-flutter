import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import 'src/authentication_api.dart';
import 'src/web_authentication.dart';

class Auth0 {
  final Account account;

  Auth0(final String domain, final String clientId)
      : account = Account(domain, clientId);

  WebAuthentication get webAuthentication => WebAuthentication(account);

  AuthenticationApi get api => AuthenticationApi(account);
}
