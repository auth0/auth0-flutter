import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile', () {
    test('fromMap correctly maps all properties', () {
      final map = {
        'sub': 'user123',
        'name': 'John Doe',
        'given_name': 'John',
        'family_name': 'Doe',
        'middle_name': 'Smith',
        'nickname': 'Johnny',
        'preferred_username': 'john.doe',
        'profile': 'https://example.com/profile',
        'picture': 'https://example.com/picture.jpg',
        'website': 'https://johndoe.com',
        'email': 'john@example.com',
        'email_verified': true,
        'gender': 'male',
        'birthdate': '1990-01-01',
        'zoneinfo': 'America/New_York',
        'locale': 'en-US',
        'phone_number': '+1234567890',
        'phone_number_verified': true,
        'address': {'country': 'USA', 'postal_code': '12345'},
        'updated_at': '2023-01-01T00:00:00.000Z',
        'custom_claims': {'role': 'admin'}
      };

      final userProfile = UserProfile.fromMap(map);

      expect(userProfile.sub, 'user123');
      expect(userProfile.name, 'John Doe');
      expect(userProfile.givenName, 'John');
      expect(userProfile.familyName, 'Doe');
      expect(userProfile.middleName, 'Smith');
      expect(userProfile.nickname, 'Johnny');
      expect(userProfile.preferredUsername, 'john.doe');
      expect(userProfile.profileUrl, Uri.parse('https://example.com/profile'));
      expect(
          userProfile.pictureUrl, Uri.parse('https://example.com/picture.jpg'));
      expect(userProfile.websiteUrl, Uri.parse('https://johndoe.com'));
      expect(userProfile.email, 'john@example.com');
      expect(userProfile.isEmailVerified, true);
      expect(userProfile.gender, 'male');
      expect(userProfile.birthdate, '1990-01-01');
      expect(userProfile.zoneinfo, 'America/New_York');
      expect(userProfile.locale, 'en-US');
      expect(userProfile.phoneNumber, '+1234567890');
      expect(userProfile.isPhoneNumberVerified, true);
      expect(userProfile.address, {'country': 'USA', 'postal_code': '12345'});
      expect(userProfile.updatedAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
      expect(userProfile.customClaims, {'role': 'admin'});
    });

    test('fromMap handles missing optional properties', () {
      final map = {'sub': 'user123'};

      final userProfile = UserProfile.fromMap(map);

      expect(userProfile.sub, 'user123');
      expect(userProfile.name, isNull);
      expect(userProfile.givenName, isNull);
      expect(userProfile.familyName, isNull);
      expect(userProfile.middleName, isNull);
      expect(userProfile.nickname, isNull);
      expect(userProfile.preferredUsername, isNull);
      expect(userProfile.profileUrl, isNull);
      expect(userProfile.pictureUrl, isNull);
      expect(userProfile.websiteUrl, isNull);
      expect(userProfile.email, isNull);
      expect(userProfile.isEmailVerified, isNull);
      expect(userProfile.gender, isNull);
      expect(userProfile.birthdate, isNull);
      expect(userProfile.zoneinfo, isNull);
      expect(userProfile.locale, isNull);
      expect(userProfile.phoneNumber, isNull);
      expect(userProfile.isPhoneNumberVerified, isNull);
      expect(userProfile.address, isNull);
      expect(userProfile.updatedAt, isNull);
      expect(userProfile.customClaims, isNull);
    });

    test('toMap correctly converts all properties', () {
      final userProfile = UserProfile(
          sub: 'user123',
          name: 'John Doe',
          givenName: 'John',
          familyName: 'Doe',
          middleName: 'Smith',
          nickname: 'Johnny',
          preferredUsername: 'john.doe',
          profileUrl: Uri.parse('https://example.com/profile'),
          pictureUrl: Uri.parse('https://example.com/picture.jpg'),
          websiteUrl: Uri.parse('https://johndoe.com'),
          email: 'john@example.com',
          isEmailVerified: true,
          gender: 'male',
          birthdate: '1990-01-01',
          zoneinfo: 'America/New_York',
          locale: 'en-US',
          phoneNumber: '+1234567890',
          isPhoneNumberVerified: true,
          address: {'country': 'USA', 'postal_code': '12345'},
          updatedAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
          customClaims: {'role': 'admin'});

      final map = userProfile.toMap();

      expect(map['sub'], 'user123');
      expect(map['name'], 'John Doe');
      expect(map['given_name'], 'John');
      expect(map['family_name'], 'Doe');
      expect(map['middle_name'], 'Smith');
      expect(map['nickname'], 'Johnny');
      expect(map['preferred_username'], 'john.doe');
      expect(map['profile'], 'https://example.com/profile');
      expect(map['picture'], 'https://example.com/picture.jpg');
      expect(map['website'], 'https://johndoe.com');
      expect(map['email'], 'john@example.com');
      expect(map['email_verified'], true);
      expect(map['gender'], 'male');
      expect(map['birthdate'], '1990-01-01');
      expect(map['zoneinfo'], 'America/New_York');
      expect(map['locale'], 'en-US');
      expect(map['phone_number'], '+1234567890');
      expect(map['phone_number_verified'], true);
      expect(map['address'], {'country': 'USA', 'postal_code': '12345'});
      expect(map['updated_at'], '2023-01-01T00:00:00.000Z');
      expect(map['custom_claims'], {'role': 'admin'});
    });
  });
}
