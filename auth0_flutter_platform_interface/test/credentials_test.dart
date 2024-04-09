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
    });

    test('Credentials throws when expiresAt Locale set to ar', () async {
      final dateTime = DateTime(2022);
      final isoDateTimeString = _formatISOTime(dateTime, 'ar');

      expect(
        () => Credentials.fromMap({
          'accessToken': 'accessToken',
          'idToken': 'idToken',
          'refreshToken': 'refreshToken',
          'expiresAt': isoDateTimeString,
          'scopes': ['a'],
          'userProfile': {'sub': '123', 'name': 'John Doe'},
          'tokenType': 'Bearer',
        }),
        throwsA(isA<FormatException>()),
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

    test('converting to a map and back again populates the user property', () {
      final dateTime = DateTime.utc(2023, 11, 2);
      final updatedAt = DateTime.utc(2024, 10, 3);
      const userName = 'User name';
      const customClaimValue = 1;
      const exampleUrl =
          'https://store.google.com/ca/product/pixel_tablet?hl=en-GB';

      final credentials = Credentials(
        accessToken: 'accessToken',
        idToken: 'idToken',
        refreshToken: 'refreshToken',
        expiresAt: dateTime,
        scopes: {'a'},
        user: UserProfile(
          sub: 'sub',
          name: userName,
          givenName: 'givenName',
          familyName: 'familyName',
          middleName: 'middleName',
          nickname: 'nickname',
          preferredUsername: 'preferredUsername',
          profileUrl: Uri.parse(exampleUrl),
          pictureUrl: Uri.parse(exampleUrl),
          websiteUrl: Uri.parse(exampleUrl),
          email: 'email',
          isEmailVerified: true,
          gender: 'gender',
          birthdate: 'birthdate',
          zoneinfo: 'zoneinfo',
          locale: 'locale',
          phoneNumber: 'phoneNumber',
          isPhoneNumberVerified: true,
          address: {
            'line_1': '123 Fox Lane',
          },
          updatedAt: updatedAt,
          customClaims: {
            'my_claim': customClaimValue,
          },
        ),
        tokenType: 'Bearer',
      );

      final result = Credentials.fromMap(credentials.toMap());

      expect(result.user.name, userName);
      expect(result.user.customClaims?['my_claim'], customClaimValue);
      expect(result.user.websiteUrl?.toString(), exampleUrl);
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
