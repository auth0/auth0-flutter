import 'dart:js_interop';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../js_interop.dart';
import 'string_extension.dart';

extension ApiCredentialsExtension on ApiCredentials {
  static ApiCredentials fromWeb(final WebCredentials webCredentials) {
    final expiresIn = webCredentials.expires_in.toDartInt;
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    return ApiCredentials(
        accessToken: webCredentials.access_token,
        tokenType: webCredentials.token_type ?? 'Bearer',
        expiresAt: expiresAt,
        scopes: {...webCredentials.scope?.splitBySingleSpace() ?? []});
  }
}
