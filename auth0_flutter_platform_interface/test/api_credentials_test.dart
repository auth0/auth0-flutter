import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiCredentials.fromMap', () {
    test('maps all properties', () async {
      final apiCredentials = ApiCredentials.fromMap({
        'accessToken': 'accessToken',
        'tokenType': 'Bearer',
        'expiresAt': '2023-11-01T22:16:35.760Z',
        'scopes': ['a', 'b'],
      });

      expect(apiCredentials.accessToken, 'accessToken');
      expect(apiCredentials.tokenType, 'Bearer');
      expect(apiCredentials.scopes, {'a', 'b'});
      expect(apiCredentials.expiresAt,
          DateTime.parse('2023-11-01T22:16:35.760Z'));
    });

    test('expiresAt is a UTC DateTime', () async {
      final apiCredentials = ApiCredentials.fromMap({
        'accessToken': 'accessToken',
        'tokenType': 'Bearer',
        'expiresAt': '2023-11-01T22:16:35.760Z',
        'scopes': <String>[],
      });

      expect(apiCredentials.expiresAt.isUtc, true);
      expect(apiCredentials.scopes, isEmpty);
    });
  });

  group('ApiCredentials.toMap', () {
    test('expiresAt is an ISO 8601 date with UTC time zone', () async {
      final apiCredentials = ApiCredentials(
        accessToken: 'accessToken',
        tokenType: 'Bearer',
        expiresAt: DateTime.utc(2023, 11, 1, 22, 16, 35, 760),
        scopes: {'a', 'b'},
      );

      final map = apiCredentials.toMap();
      expect(map['accessToken'], 'accessToken');
      expect(map['tokenType'], 'Bearer');
      expect(map['expiresAt'], '2023-11-01T22:16:35.760Z');
      expect(map['scopes'], ['a', 'b']);
    });
  });

  group('GetApiCredentialsOptions.toMap', () {
    test('maps all properties', () async {
      final map = GetApiCredentialsOptions(
        audience: 'test-audience',
        scopes: {'a', 'b'},
        minTtl: 30,
        parameters: {'p': '1'},
        headers: {'h': '2'},
      ).toMap();

      expect(map['audience'], 'test-audience');
      expect(map['scopes'], ['a', 'b']);
      expect(map['minTtl'], 30);
      expect(map['parameters'], {'p': '1'});
      expect(map['headers'], {'h': '2'});
    });

    test('applies defaults to non-required properties', () async {
      final map = GetApiCredentialsOptions(audience: 'test-audience').toMap();

      expect(map['audience'], 'test-audience');
      expect(map['scopes'], isEmpty);
      expect(map['minTtl'], 0);
      expect(map['parameters'], isEmpty);
      expect(map['headers'], isEmpty);
    });
  });

  group('ClearApiCredentialsOptions.toMap', () {
    test('includes the scope when provided', () async {
      final map = ClearApiCredentialsOptions(
        audience: 'test-audience',
        scope: 'test-scope',
      ).toMap();

      expect(map['audience'], 'test-audience');
      expect(map['scope'], 'test-scope');
    });

    test('omits the scope when not provided', () async {
      final map = ClearApiCredentialsOptions(audience: 'test-audience').toMap();

      expect(map['audience'], 'test-audience');
      expect(map.containsKey('scope'), false);
    });
  });
}
