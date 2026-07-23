@Tags(['browser'])

import 'dart:convert';
import 'dart:js_interop';
import 'package:auth0_flutter/src/web/extensions/credentials_extension.dart';
import 'package:auth0_flutter/src/web/extensions/string_extension.dart';
import 'package:auth0_flutter/src/web/js_interop.dart';
import 'package:auth0_flutter/src/web/jwt_decode.dart';
import 'package:flutter_test/flutter_test.dart';

const idToken =
    'HEADER.eyJzdWIiOiJjb20uc29td2hlcmUuZmFyLmJleW9uZDphcGkiLCJpc3Mi'
    'OiJhdXRoMCIsInVzZXJfcm9sZSI6ImFkbWluIn0.SIGNATURE';

/// Builds a JWT-shaped string whose payload contains the given [claims].
String _tokenWithClaims(final Map<String, dynamic> claims) {
  final body = <String, dynamic>{'sub': '123', ...claims};
  final payload =
      base64Url.encode(utf8.encode(jsonEncode(body))).replaceAll('=', '');
  return 'HEADER.$payload.SIGNATURE';
}

void main() {
  group('CredentialsExtension', () {
    test('creates Credentials from WebCredentials with required values', () {
      const accessToken = 'foo';
      const expiresIn = 8400;
      const expectedTokenType = 'Bearer';
      final webCredentials = WebCredentials(
        access_token: accessToken,
        id_token: idToken,
        expires_in: expiresIn.toJS,
      );
      final result = CredentialsExtension.fromWeb(webCredentials);

      expect(result.accessToken, accessToken);
      expect(result.idToken, idToken);
      expect(
          result.expiresAt.difference(
            DateTime.now().add(const Duration(seconds: expiresIn)),
          ),
          lessThan(const Duration(seconds: 1)));
      expect(result.user.sub, JWT.decode(idToken)['sub']);
      expect(result.tokenType, expectedTokenType);
      expect(result.refreshToken, isNull);
      expect(result.scopes, isEmpty);
    });

    test('creates Credentials from WebCredentials with optional values', () {
      const accessToken = '';
      const expiresIn = 1;
      const refreshToken = 'foo';
      const scope = 'openid profile email';
      final webCredentials = WebCredentials(
          access_token: accessToken,
          id_token: idToken,
          expires_in: expiresIn.toJS,
          refresh_token: refreshToken,
          scope: scope);
      final result = CredentialsExtension.fromWeb(webCredentials);

      expect(result.refreshToken, refreshToken);
      expect(result.scopes, {...scope.splitBySingleSpace()});
    });

    test('decodes sessionExpiry from the session_expiry claim', () {
      // 2023-11-02T10:00:00Z == 1698919200 Unix seconds.
      const sessionExpirySeconds = 1698919200;
      final webCredentials = WebCredentials(
        access_token: 'foo',
        id_token: _tokenWithClaims({'session_expiry': sessionExpirySeconds}),
        expires_in: 3600.toJS,
      );
      final result = CredentialsExtension.fromWeb(webCredentials);

      expect(result.sessionExpiry, isNotNull);
      expect(result.sessionExpiry!.isUtc, true);
      expect(result.sessionExpiry!.millisecondsSinceEpoch,
          sessionExpirySeconds * 1000);
    });

    test('sessionExpiry is null when the claim is absent', () {
      final webCredentials = WebCredentials(
        access_token: 'foo',
        id_token: _tokenWithClaims({}),
        expires_in: 3600.toJS,
      );
      final result = CredentialsExtension.fromWeb(webCredentials);

      expect(result.sessionExpiry, isNull);
    });
  });
}
