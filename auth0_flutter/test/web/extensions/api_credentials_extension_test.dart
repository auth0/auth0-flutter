@Tags(['browser'])

import 'dart:js_interop';
import 'package:auth0_flutter/src/web/extensions/api_credentials_extension.dart';
import 'package:auth0_flutter/src/web/extensions/string_extension.dart';
import 'package:auth0_flutter/src/web/js_interop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiCredentialsExtension', () {
    test('creates ApiCredentials from WebCredentials with required values', () {
      const accessToken = 'foo';
      const expiresIn = 8400;
      const expectedTokenType = 'Bearer';
      final webCredentials = WebCredentials(
        access_token: accessToken,
        id_token: 'id',
        expires_in: expiresIn.toJS,
      );

      final result = ApiCredentialsExtension.fromWeb(webCredentials);

      expect(result.accessToken, accessToken);
      expect(result.tokenType, expectedTokenType);
      expect(
          result.expiresAt.difference(
            DateTime.now().add(const Duration(seconds: expiresIn)),
          ),
          lessThan(const Duration(seconds: 1)));
      expect(result.scopes, isEmpty);
    });

    test('creates ApiCredentials from WebCredentials with optional values', () {
      const accessToken = 'token';
      const expiresIn = 1;
      const scope = 'openid profile read:messages';
      const tokenType = 'DPoP';
      final webCredentials = WebCredentials(
          access_token: accessToken,
          id_token: 'id',
          expires_in: expiresIn.toJS,
          scope: scope,
          token_type: tokenType);

      final result = ApiCredentialsExtension.fromWeb(webCredentials);

      expect(result.tokenType, tokenType);
      expect(result.scopes, {...scope.splitBySingleSpace()});
    });
  });
}
