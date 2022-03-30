import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'account.dart';

class WebAuthentication {
  final Account account;

  WebAuthentication(this.account);

  Future<LoginResult> login(
          {final String? audience,
          final Set<String> scopes = const {},
          final String? redirectUri,
          final String? organizationId,
          final String? invitationUrl,
          final bool useEphemeralSession = false,
          final Map<String, Object> parameters = const {},
          final IdTokenValidationConfig idTokenValidationConfig =
              const IdTokenValidationConfig()}) =>
      Auth0FlutterWebAuthPlatform.instance.login(WebAuthLoginOptions(
          audience: 'audience', scopes: {'a'}, redirectUri: 'redirect uri'));

  Future<void> logout({final String? returnTo}) => Future.value();
}
