import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../utils/string_extension.dart';
import 'js_interop.dart';
import 'jwt_decode.dart';
import 'user_profile_extension.dart';

extension CredentialsExtension on Credentials {
  static Credentials fromWeb(final WebCredentials webCredentials) {
    final expiresIn = webCredentials.expires_in as int;
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    final claims = JWT.decode(webCredentials.id_token);
    final user = UserProfileExtension.fromClaims(claims);

    return Credentials(
        idToken: webCredentials.id_token,
        accessToken: webCredentials.access_token,
        expiresAt: expiresAt,
        user: user,
        refreshToken: webCredentials.refresh_token,
        scopes: {...webCredentials.scope?.splitBySingleSpace() ?? {}},
        tokenType: 'Bearer');
  }
}
