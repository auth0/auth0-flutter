import 'dart:convert';

import 'package:auth0_flutter/src/web/jwt_decode.dart';
import 'package:auth0_flutter/src/web/jwt_decode_exception.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JWTDecode', () {
    test('decodes a JWT payload', () async {
      const jwt = 'HEADER.eyJzdWIiOiJjb20uc29td2hlcmUuZmFyLmJleW9uZDphcGkiLCJpc'
          '3MiOiJhdXRoMCIsInVzZXJfcm9sZSI6ImFkbWluIn0.SIGNATURE';
      final result = JWT.decode(jwt);

      expect(result, isNotNull);
    });

    test('decodes an empty JWT payload', () async {
      const payload = 'e30'; // Valid Base64, invalid Base64URL
      const jwt = 'HEADER.$payload.SIGNATURE';
      final result = JWT.decode(jwt);

      expect(result, isNotNull);
    });

    test('returns the decoded payload', () async {
      const data = {'sub': 1, 'foo': 'bar'};
      final payload = base64Url.encode(utf8.encode(jsonEncode(data)));
      final jwt = 'HEADER.$payload.SIGNATURE';
      final result = JWT.decode(jwt);

      expect(result, equals(data));
    });

    test('throws an exception with an invalid Base64URL payload', () async {
      const payload = '+'; // Valid Base64, invalid Base64URL
      const jwt = 'HEADER.$payload.SIGNATURE';
      const expectedCode = 'INVALID_BASE64URL';
      const expectedMessage = 'Failed to decode Base64URL value $payload.';

      expect(() => JWT.decode(jwt),
          throwsJWTDecodeException(expectedCode, expectedMessage));
    });

    test('throws an exception with an invalid JSON payload', () async {
      const payload = 'Qk9EWQ==';
      const jwt = 'HEADER.$payload.SIGNATURE';
      const expectedCode = 'INVALID_JSON';
      const expectedMessage =
          'Failed to parse JSON from Base64URL value $payload.';

      expect(() => JWT.decode(jwt),
          throwsJWTDecodeException(expectedCode, expectedMessage));
    });

    test('throws an exception with a malformed JWT', () async {
      const jwt = 'HEADER.eyJzdWIiOiIxIn0';
      const expectedCode = 'INVALID_PART_COUNT';
      const expectedMessage =
          'The JWT $jwt has 2 parts when it should have 3 parts.';

      expect(() => JWT.decode(jwt),
          throwsJWTDecodeException(expectedCode, expectedMessage));
    });
  });
}

Matcher throwsJWTDecodeException(final String code, final String message) =>
    throwsA(Auth0ExceptionMatcher<JWTDecodeException>(code, message));
