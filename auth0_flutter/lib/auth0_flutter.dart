import 'dart:async';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'src/account.dart';
import 'src/web_authentication.dart';
export 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

class WebAuthAuth0Flutter {
  static Future<WebAuthLoginResult?> get login async =>
      Auth0FlutterWebAuthPlatform.instance.login(WebAuthLoginOptions(
          audience: 'audience', scopes: {'a'}, redirectUri: 'redirect uri'));
}

class Auth0 {
  final Account account;

  Auth0(final String domain, final String clientId)
      : account = Account(domain, clientId);

  WebAuthentication get webAuthentication => WebAuthentication(account);
}

class AuthAuth0Flutter {
  static Future<AuthLoginResult?> get login async =>
      Auth0FlutterAuthPlatform.instance.login(AuthLoginOptions(
          usernameOrEmail: '', password: '', connectionOrRealm: ''));
}
