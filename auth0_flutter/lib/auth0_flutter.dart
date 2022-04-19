import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import 'src/authentication_api.dart';
import 'src/version.dart';
import 'src/web_authentication.dart';

export 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart'
    show WebAuthException, ApiException;

class Auth0 {
  final Account account;
  final Telemetry telemetry = Telemetry(name: 'auth0-flutter', version: version);

  Auth0(final String domain, final String clientId)
      : account = Account(domain, clientId);

  WebAuthentication get webAuthentication => WebAuthentication(account, telemetry);

  AuthenticationApi get api => AuthenticationApi(account, telemetry);
}
