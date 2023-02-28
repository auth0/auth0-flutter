@Tags(['browser'])

import 'package:auth0_flutter/src/utils/string_extension.dart';
import 'package:auth0_flutter/src/web/credentials_extension.dart';
import 'package:auth0_flutter/src/web/js_interop.dart';
import 'package:auth0_flutter/src/web/jwt_decode.dart';
import 'package:flutter_test/flutter_test.dart';

const idToken =
    'HEADER.eyJzdWIiOiJjb20uc29td2hlcmUuZmFyLmJleW9uZDphcGkiLCJpc3Mi'
    'OiJhdXRoMCIsInVzZXJfcm9sZSI6ImFkbWluIn0.SIGNATURE';

void main() {
  group('CredentialsExtension', () {
    test('creates Credentials from WebCredentials with required values', () {
      const accessToken = 'foo';
      const expiresIn = 8400;
      const expectedTokenType = 'Bearer';
      final webCredentials = WebCredentials(
          access_token: accessToken, id_token: idToken, expires_in: expiresIn);
      final result = CredentialsExtension.fromWeb(webCredentials);

      expect(result.accessToken, accessToken);
      expect(result.idToken, idToken);
      expect(
          result.expiresAt.difference(
              DateTime.now().add(const Duration(seconds: expiresIn))),
          lessThan(const Duration(seconds: 1)));
      expect(result.user.sub, JWT.decode(idToken)['sub']);
      expect(result.tokenType, expectedTokenType);
    });

    test('creates Credentials from WebCredentials with optional values', () {
      const accessToken = '';
      const expiresIn = 1;
      const refreshToken = 'foo';
      const scope = 'openid profile email';
      final webCredentials = WebCredentials(
          access_token: accessToken,
          id_token: idToken,
          expires_in: expiresIn,
          refresh_token: refreshToken,
          scope: scope);
      final result = CredentialsExtension.fromWeb(webCredentials);

      expect(result.refreshToken, refreshToken);
      expect(result.scopes, {...scope.splitBySingleSpace()});
    });
  });
}
