import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  initializeDateFormatting();

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

  test('Credentials does not throw when expiresAt Locale set to US', () async {
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
}

String _formatISOTime(final DateTime date, final String locale) {
  final duration = date.timeZoneOffset;
  if (duration.isNegative) {
    return "${DateFormat('yyyy-MM-ddTHH:mm:ss.mmm', locale).format(date)}-${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}";
  } else {
    return "${DateFormat('yyyy-MM-ddTHH:mm:ss.mmm', locale).format(date)}+${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}";
  }
}
