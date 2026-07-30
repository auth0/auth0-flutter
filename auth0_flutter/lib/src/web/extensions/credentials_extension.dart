import 'dart:js_interop';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../js_interop.dart';
import '../jwt_decode.dart';
import 'string_extension.dart';
import 'user_profile_extension.dart';

extension CredentialsExtension on Credentials {
  static Credentials fromWeb(final WebCredentials webCredentials) {
    final expiresIn = webCredentials.expires_in.toDartInt;
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    final claims = JWT.decode(webCredentials.id_token);
    final user = UserProfileExtension.fromClaims(claims);
    // IPSIE session_expiry ceiling. auth0-spa-js (>= 2.22.0) enforces it on
    // silent renewal; here we only surface the value. Reject values outside
    // `(0, 10_000_000_000)` to match the native SDKs — the upper bound discards
    // millisecond-valued timestamps that would surface a bogus far-future
    // ceiling.
    final Object? sessionExpiryClaim = claims['session_expiry'];
    final sessionExpiry = sessionExpiryClaim is num &&
            sessionExpiryClaim > 0 &&
            sessionExpiryClaim < 10000000000
        ? DateTime.fromMillisecondsSinceEpoch(
            sessionExpiryClaim.toInt() * 1000,
            isUtc: true,
          )
        : null;
    return Credentials(
        idToken: webCredentials.id_token,
        accessToken: webCredentials.access_token,
        expiresAt: expiresAt,
        user: user,
        refreshToken: webCredentials.refresh_token,
        scopes: {...webCredentials.scope?.splitBySingleSpace() ?? []},
        tokenType: webCredentials.token_type ?? 'Bearer',
        sessionExpiry: sessionExpiry);
  }
}
