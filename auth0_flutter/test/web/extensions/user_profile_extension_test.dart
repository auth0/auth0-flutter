import 'package:auth0_flutter/src/web/extensions/user_profile_extension.dart';
import 'package:flutter_test/flutter_test.dart';

const requiredValues = {PublicClaims.sub: 'foo'};

void main() {
  group('UserProfileExtension', () {
    test('creates UserProfile from claims with required values', () async {
      final result = UserProfileExtension.fromClaims(requiredValues);

      expect(result.sub, requiredValues[PublicClaims.sub]);
      expect(result.name, isNull);
      expect(result.givenName, isNull);
      expect(result.familyName, isNull);
      expect(result.middleName, isNull);
      expect(result.nickname, isNull);
      expect(result.preferredUsername, isNull);
      expect(result.profileUrl, isNull);
      expect(result.pictureUrl, isNull);
      expect(result.websiteUrl, isNull);
      expect(result.email, isNull);
      expect(result.isEmailVerified, isNull);
      expect(result.gender, isNull);
      expect(result.birthdate, isNull);
      expect(result.zoneinfo, isNull);
      expect(result.locale, isNull);
      expect(result.phoneNumber, isNull);
      expect(result.isPhoneNumberVerified, isNull);
      expect(result.address, isNull);
      expect(result.updatedAt, isNull);
      expect(result.customClaims, isNull);
    });

    test('creates UserProfile from claims with optional values', () async {
      const Map<String, dynamic> claims = {
        ...requiredValues,
        PublicClaims.name: 'John Alexander Doe',
        PublicClaims.givenName: 'John',
        PublicClaims.familyName: 'Doe',
        PublicClaims.middleName: 'Alexander',
        PublicClaims.nickname: 'johnny',
        PublicClaims.preferredUsername: 'johnnyD',
        PublicClaims.profile: 'https://example.com/profile',
        PublicClaims.picture: 'https://example.com/picture.png',
        PublicClaims.website: 'https://example.com',
        PublicClaims.email: 'john.doe@example.com',
        PublicClaims.emailVerified: true,
        PublicClaims.gender: 'male',
        PublicClaims.birthdate: '01-01-2000',
        PublicClaims.zoneinfo: 'America/Chicago',
        PublicClaims.locale: 'en-US',
        PublicClaims.phoneNumber: '111111111',
        PublicClaims.phoneNumberVerified: true,
        PublicClaims.address: {'street': '1 Foo St', 'zip_code': '11111-1111'},
        PublicClaims.updatedAt: '2023-02-28T15:08:56+00:00',
        'foo': 'bar'
      };

      final result = UserProfileExtension.fromClaims(claims);

      expect(result.name, claims[PublicClaims.name]);
      expect(result.givenName, claims[PublicClaims.givenName]);
      expect(result.familyName, claims[PublicClaims.familyName]);
      expect(result.middleName, claims[PublicClaims.middleName]);
      expect(result.nickname, claims[PublicClaims.nickname]);
      expect(result.preferredUsername, claims[PublicClaims.preferredUsername]);
      expect(
          result.profileUrl, Uri.parse(claims[PublicClaims.profile] as String));
      expect(
          result.pictureUrl, Uri.parse(claims[PublicClaims.picture] as String));
      expect(
          result.websiteUrl, Uri.parse(claims[PublicClaims.website] as String));
      expect(result.email, claims[PublicClaims.email]);
      expect(result.isEmailVerified, claims[PublicClaims.emailVerified]);
      expect(result.gender, claims[PublicClaims.gender]);
      expect(result.birthdate, claims[PublicClaims.birthdate]);
      expect(result.zoneinfo, claims[PublicClaims.zoneinfo]);
      expect(result.locale, claims[PublicClaims.locale]);
      expect(result.phoneNumber, claims[PublicClaims.phoneNumber]);
      expect(result.isPhoneNumberVerified,
          claims[PublicClaims.phoneNumberVerified]);
      expect(result.address, claims[PublicClaims.address]);
      expect(result.updatedAt,
          DateTime.parse(claims[PublicClaims.updatedAt] as String));
      expect(result.customClaims?['foo'], claims['foo']);
    });

    test('removes registered and public claims from custom claims', () async {
      const customClaims = {'foo': 'bar', 'baz': 'quux'};
      const Map<String, dynamic> claims = {
        RegisteredClaims.aud: '',
        RegisteredClaims.iss: '',
        RegisteredClaims.iat: '',
        RegisteredClaims.exp: '',
        RegisteredClaims.nbf: '',
        RegisteredClaims.nonce: '',
        RegisteredClaims.azp: '',
        RegisteredClaims.authTime: '',
        RegisteredClaims.sHash: '',
        RegisteredClaims.atHash: '',
        RegisteredClaims.cHash: '',
        PublicClaims.sub: '',
        PublicClaims.name: '',
        PublicClaims.givenName: '',
        PublicClaims.familyName: '',
        PublicClaims.middleName: '',
        PublicClaims.nickname: '',
        PublicClaims.preferredUsername: '',
        PublicClaims.profile: '',
        PublicClaims.picture: '',
        PublicClaims.website: '',
        PublicClaims.email: '',
        PublicClaims.emailVerified: false,
        PublicClaims.gender: '',
        PublicClaims.birthdate: '',
        PublicClaims.zoneinfo: '',
        PublicClaims.locale: '',
        PublicClaims.phoneNumber: '',
        PublicClaims.phoneNumberVerified: false,
        PublicClaims.address: <String, dynamic>{},
        PublicClaims.updatedAt: '2023-02-28',
        ...customClaims
      };

      final result = UserProfileExtension.fromClaims(claims);

      expect(result.customClaims?.length, customClaims.length);
      expect(result.customClaims, customClaims);
    });

    test('creates UserProfile from claims with stringified email_verified',
        () async {
      const Map<String, dynamic> claims = {
        ...requiredValues,
        PublicClaims.name: 'John Alexander Doe',
        PublicClaims.givenName: 'John',
        PublicClaims.familyName: 'Doe',
        PublicClaims.middleName: 'Alexander',
        PublicClaims.nickname: 'johnny',
        PublicClaims.preferredUsername: 'johnnyD',
        PublicClaims.profile: 'https://example.com/profile',
        PublicClaims.picture: 'https://example.com/picture.png',
        PublicClaims.website: 'https://example.com',
        PublicClaims.email: 'john.doe@example.com',
        PublicClaims.emailVerified: 'true',
        PublicClaims.gender: 'male',
        PublicClaims.birthdate: '01-01-2000',
        PublicClaims.zoneinfo: 'America/Chicago',
        PublicClaims.locale: 'en-US',
        PublicClaims.phoneNumber: '111111111',
        PublicClaims.phoneNumberVerified: true,
        PublicClaims.address: {'street': '1 Foo St', 'zip_code': '11111-1111'},
        PublicClaims.updatedAt: '2023-02-28T15:08:56+00:00',
        'foo': 'bar'
      };

      final result = UserProfileExtension.fromClaims(claims);

      expect(result.name, claims[PublicClaims.name]);
      expect(result.givenName, claims[PublicClaims.givenName]);
      expect(result.familyName, claims[PublicClaims.familyName]);
      expect(result.middleName, claims[PublicClaims.middleName]);
      expect(result.nickname, claims[PublicClaims.nickname]);
      expect(result.preferredUsername, claims[PublicClaims.preferredUsername]);
      expect(
          result.profileUrl, Uri.parse(claims[PublicClaims.profile] as String));
      expect(
          result.pictureUrl, Uri.parse(claims[PublicClaims.picture] as String));
      expect(
          result.websiteUrl, Uri.parse(claims[PublicClaims.website] as String));
      expect(result.email, claims[PublicClaims.email]);
      expect(result.isEmailVerified, claims[PublicClaims.emailVerified]);
      expect(result.gender, claims[PublicClaims.gender]);
      expect(result.birthdate, claims[PublicClaims.birthdate]);
      expect(result.zoneinfo, claims[PublicClaims.zoneinfo]);
      expect(result.locale, claims[PublicClaims.locale]);
      expect(result.phoneNumber, claims[PublicClaims.phoneNumber]);
      expect(result.isPhoneNumberVerified,
          claims[PublicClaims.phoneNumberVerified]);
      expect(result.address, claims[PublicClaims.address]);
      expect(result.updatedAt,
          DateTime.parse(claims[PublicClaims.updatedAt] as String));
      expect(result.customClaims?['foo'], claims['foo']);
    });

    test('throws exception with invalid profile URL', () async {
      const Map<String, dynamic> claims = {
        ...requiredValues,
        PublicClaims.profile: '::INVALID::'
      };

      expect(() => UserProfileExtension.fromClaims(claims), throwsException);
    });

    test('throws exception with invalid picture URL', () async {
      const Map<String, dynamic> claims = {
        ...requiredValues,
        PublicClaims.picture: '::INVALID::'
      };

      expect(() => UserProfileExtension.fromClaims(claims), throwsException);
    });

    test('throws exception with invalid website URL', () async {
      const Map<String, dynamic> claims = {
        ...requiredValues,
        PublicClaims.website: '::INVALID::'
      };

      expect(() => UserProfileExtension.fromClaims(claims), throwsException);
    });

    test('throws exception with invalid updated_at date', () async {
      const Map<String, dynamic> claims = {
        ...requiredValues,
        PublicClaims.updatedAt: 'INVALID'
      };

      expect(() => UserProfileExtension.fromClaims(claims), throwsException);
    });
  });
}
