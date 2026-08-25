import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SSOCredentials.fromMap', () {
    test('parses all properties, converting expiresAt to a UTC DateTime', () {
      final sut = SSOCredentials.fromMap(const {
        'sessionTransferToken': 'ssoToken',
        'tokenType': 'session_transfer',
        'expiresAt': '2024-11-01T22:16:35.000Z',
        'idToken': 'idToken',
        'refreshToken': 'refreshToken',
      });

      expect(sut.sessionTransferToken, 'ssoToken');
      expect(sut.tokenType, 'session_transfer');
      expect(sut.expiresAt, DateTime.utc(2024, 11, 1, 22, 16, 35));
      expect(sut.expiresAt.isUtc, isTrue);
      expect(sut.idToken, 'idToken');
      expect(sut.refreshToken, 'refreshToken');
    });

    test('normalizes a non-UTC expiresAt to UTC', () {
      final sut = SSOCredentials.fromMap(const {
        'sessionTransferToken': 'ssoToken',
        'tokenType': 'session_transfer',
        'expiresAt': '2024-11-01T22:16:35.000+02:00',
        'idToken': 'idToken',
      });

      expect(sut.expiresAt.isUtc, isTrue);
      expect(sut.expiresAt, DateTime.utc(2024, 11, 1, 20, 16, 35));
      expect(sut.refreshToken, isNull);
    });
  });

  group('SSOCredentials.toMap', () {
    test('emits expiresAt as an ISO-8601 UTC string', () {
      final map = SSOCredentials(
        sessionTransferToken: 'ssoToken',
        tokenType: 'session_transfer',
        expiresAt: DateTime.utc(2024, 11, 1, 22, 16, 35),
        idToken: 'idToken',
        refreshToken: 'refreshToken',
      ).toMap();

      expect(map['sessionTransferToken'], 'ssoToken');
      expect(map['tokenType'], 'session_transfer');
      expect(map['expiresAt'], '2024-11-01T22:16:35.000Z');
      expect(map['idToken'], 'idToken');
      expect(map['refreshToken'], 'refreshToken');
    });
  });

  test('fromMap/toMap round-trip preserves values', () {
    final original = SSOCredentials(
      sessionTransferToken: 'ssoToken',
      tokenType: 'session_transfer',
      expiresAt: DateTime.utc(2024, 11, 1, 22, 16, 35),
      idToken: 'idToken',
      refreshToken: 'refreshToken',
    );

    final roundTripped = SSOCredentials.fromMap(original.toMap());

    expect(roundTripped.sessionTransferToken, original.sessionTransferToken);
    expect(roundTripped.tokenType, original.tokenType);
    expect(roundTripped.expiresAt, original.expiresAt);
    expect(roundTripped.idToken, original.idToken);
    expect(roundTripped.refreshToken, original.refreshToken);
  });
}
