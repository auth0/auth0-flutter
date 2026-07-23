import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  initializeDateFormatting();

  group('Credentials.fromMap', () {
    test('expiresAt is a UTC DateTime', () async {
      const isoDateTimeString = '2023-11-01T22:16:35.760Z';
      final credentials = Credentials.fromMap({
        'accessToken': 'accessToken',
        'idToken': 'idToken',
        'refreshToken': 'refreshToken',
        'expiresAt': isoDateTimeString,
        'scopes': ['a'],
        'userProfile': {'sub': '123', 'name': 'John Doe'},
        'tokenType': 'Bearer',
      });

      expect(credentials.expiresAt.isUtc, true);
      expect(
        credentials.toMap()['userProfile']['sub'],
        '123',
      );
      expect(
        credentials.toMap()['userProfile']['name'],
        'John Doe',
      );
    });

    test('Credentials does not throw when expiresAt Locale set to ar',
        () async {
      initializeDateFormatting();
      final dateTime = DateTime(2022);
      final isoDateTimeString = _formatISOTime(dateTime, 'ar');

      expect(
        Credentials.fromMap({
          'accessToken': 'accessToken',
          'idToken': 'idToken',
          'refreshToken': 'refreshToken',
          'expiresAt': isoDateTimeString,
          'scopes': ['a'],
          'userProfile': {'sub': '123', 'name': 'John Doe'},
          'tokenType': 'Bearer',
        }),
        isA<Credentials>(),
      );
    });

    test('Credentials does not throw when expiresAt Locale set to US',
        () async {
      initializeDateFormatting();
      final dateTime = DateTime(2022);
      final isoDateTimeString = _formatISOTime(dateTime, 'en_US');

      expect(
        Credentials.fromMap({
          'accessToken': 'accessToken',
          'idToken': 'idToken',
          'refreshToken': 'refreshToken',
          'expiresAt': isoDateTimeString,
          'scopes': ['a'],
          'userProfile': {'sub': '123', 'name': 'John Doe'},
          'tokenType': 'Bearer',
        }),
        isA<Credentials>(),
      );
    });

    test('sessionExpiry is a UTC DateTime when present', () async {
      const isoDateTimeString = '2023-11-01T22:16:35.760Z';
      final credentials = Credentials.fromMap({
        'accessToken': 'accessToken',
        'idToken': 'idToken',
        'refreshToken': 'refreshToken',
        'expiresAt': isoDateTimeString,
        'scopes': ['a'],
        'userProfile': {'sub': '123', 'name': 'John Doe'},
        'tokenType': 'Bearer',
        'sessionExpiry': '2023-11-02T10:00:00.000Z',
      });

      expect(credentials.sessionExpiry, isNotNull);
      expect(credentials.sessionExpiry!.isUtc, true);
      expect(credentials.sessionExpiry,
          DateTime.utc(2023, 11, 2, 10));
    });

    test('sessionExpiry is null when the claim is absent', () async {
      const isoDateTimeString = '2023-11-01T22:16:35.760Z';
      final credentials = Credentials.fromMap({
        'accessToken': 'accessToken',
        'idToken': 'idToken',
        'refreshToken': 'refreshToken',
        'expiresAt': isoDateTimeString,
        'scopes': ['a'],
        'userProfile': {'sub': '123', 'name': 'John Doe'},
        'tokenType': 'Bearer',
      });

      expect(credentials.sessionExpiry, isNull);
    });
  });

  group('toMap', () {
    test('expiresAt is a ISO 8601 date with UTC time zone', () async {
      final dateTime = DateTime(2023, 11, 1, 22, 16, 35, 760);
      final credentials = Credentials(
          accessToken: 'accessToken',
          idToken: 'idToken',
          refreshToken: 'refreshToken',
          expiresAt: dateTime,
          scopes: {'a'},
          user: const UserProfile(sub: '123', name: 'John Doe'),
          tokenType: 'Bearer');

      expect(credentials.toMap()['expiresAt'], '2023-11-01T22:16:35.760Z');
    });

    test('sessionExpiry is an ISO 8601 UTC date when set', () async {
      final credentials = Credentials(
          accessToken: 'accessToken',
          idToken: 'idToken',
          refreshToken: 'refreshToken',
          expiresAt: DateTime(2023, 11, 1, 22, 16, 35, 760),
          scopes: {'a'},
          user: const UserProfile(sub: '123', name: 'John Doe'),
          tokenType: 'Bearer',
          sessionExpiry: DateTime.utc(2023, 11, 2, 10));

      expect(credentials.toMap()['sessionExpiry'], '2023-11-02T10:00:00.000Z');
    });

    test('sessionExpiry is null in the map when not set', () async {
      final credentials = Credentials(
          accessToken: 'accessToken',
          idToken: 'idToken',
          refreshToken: 'refreshToken',
          expiresAt: DateTime(2023, 11, 1, 22, 16, 35, 760),
          scopes: {'a'},
          user: const UserProfile(sub: '123', name: 'John Doe'),
          tokenType: 'Bearer');

      expect(credentials.toMap()['sessionExpiry'], isNull);
    });
  });
}

String _formatISOTime(final DateTime date, final String locale) {
  final duration = date.timeZoneOffset;
  final stringDate = DateFormat('yyyy-MM-ddTHH:mm:ss.mmm', locale).format(date);
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes =
      (duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0');
  if (duration.isNegative) {
    return '$stringDate-$hours$minutes';
  }
  return '$stringDate+$hours$minutes';
}
