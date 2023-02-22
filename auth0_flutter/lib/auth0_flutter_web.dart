import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'src/version.dart';
import 'src/web/js_interop.dart';

class Auth0Web {
  final Account _account;

  final UserAgent _userAgent =
      UserAgent(name: 'auth0-flutter', version: version);

  Auth0Web(final String domain, final String clientId)
      : _account = Account(domain, clientId);

  Future<Credentials?> onLoad() async {
    Auth0FlutterWebPlatform.instance.initialize(_account);

    // Get credentials here and return them?

    return null;
  }

  Future<void> loginWithRedirect(
          {final String? audience, final String? redirectUri}) =>
      Auth0FlutterWebPlatform.instance.loginWithRedirect(
          LoginOptions(audience: audience, redirectUrl: redirectUri));
}
