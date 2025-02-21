import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

extension UserProfileExtension on UserProfile {
  static UserProfile fromClaims(final Map<String, dynamic> claims) {
    final customClaims = {...claims};
    final claimsToRemove = [
      ...RegisteredClaims.toList(),
      ...PublicClaims.toList()
    ];

    for (final key in claimsToRemove) {
      customClaims.remove(key);
    }

    final profileUrl = claims[PublicClaims.profile] != null
        ? Uri.parse(claims[PublicClaims.profile] as String)
        : null;
    final pictureUrl = claims[PublicClaims.picture] != null
        ? Uri.parse(claims[PublicClaims.picture] as String)
        : null;
    final websiteUrl = claims[PublicClaims.website] != null
        ? Uri.parse(claims[PublicClaims.website] as String)
        : null;
    final address = claims[PublicClaims.address] != null
        ? Map<String, String>.from(
            claims[PublicClaims.address] as Map<dynamic, dynamic>)
        : null;
    final updatedAt = claims[PublicClaims.updatedAt] != null
        ? DateTime.parse(claims[PublicClaims.updatedAt] as String)
        : null;
    final isEmailVerified = claims[PublicClaims.emailVerified] != null
        ? claims[PublicClaims.emailVerified] is bool
            ? claims[PublicClaims.emailVerified] as bool
            : claims[PublicClaims.emailVerified] == 'true'
        : null;
    final isPhoneVerified = claims[PublicClaims.phoneNumberVerified] != null
        ? claims[PublicClaims.phoneNumberVerified] is bool
            ? claims[PublicClaims.phoneNumberVerified] as bool
            : claims[PublicClaims.phoneNumberVerified] == 'true'
        : null;
    final locale = claims[PublicClaims.locale] != null &&
            claims[PublicClaims.locale] is String
        ? claims[PublicClaims.locale] as String
        : null;

    return UserProfile(
      sub: claims[PublicClaims.sub] as String,
      name: claims[PublicClaims.name] as String?,
      givenName: claims[PublicClaims.givenName] as String?,
      familyName: claims[PublicClaims.familyName] as String?,
      middleName: claims[PublicClaims.middleName] as String?,
      nickname: claims[PublicClaims.nickname] as String?,
      preferredUsername: claims[PublicClaims.preferredUsername] as String?,
      profileUrl: profileUrl,
      pictureUrl: pictureUrl,
      websiteUrl: websiteUrl,
      email: claims[PublicClaims.email] as String?,
      isEmailVerified: isEmailVerified,
      gender: claims[PublicClaims.gender] as String?,
      birthdate: claims[PublicClaims.birthdate] as String?,
      zoneinfo: claims[PublicClaims.zoneinfo] as String?,
      locale: locale,
      phoneNumber: claims[PublicClaims.phoneNumber] as String?,
      isPhoneNumberVerified: isPhoneVerified,
      address: address,
      updatedAt: updatedAt,
      customClaims: customClaims.isNotEmpty ? customClaims : null,
    );
  }
}

class RegisteredClaims {
  static const aud = 'aud';
  static const iss = 'iss';
  static const iat = 'iat';
  static const exp = 'exp';
  static const nbf = 'nbf';
  static const nonce = 'nonce';
  static const azp = 'azp';
  static const authTime = 'auth_time';
  static const sHash = 's_hash';
  static const atHash = 'at_hash';
  static const cHash = 'c_hash';

  static List<String> toList() => [
        RegisteredClaims.aud,
        RegisteredClaims.iss,
        RegisteredClaims.iat,
        RegisteredClaims.exp,
        RegisteredClaims.nbf,
        RegisteredClaims.nonce,
        RegisteredClaims.azp,
        RegisteredClaims.authTime,
        RegisteredClaims.sHash,
        RegisteredClaims.atHash,
        RegisteredClaims.cHash
      ];
}

class PublicClaims {
  static const sub = 'sub';
  static const name = 'name';
  static const givenName = 'given_name';
  static const familyName = 'family_name';
  static const middleName = 'middle_name';
  static const nickname = 'nickname';
  static const preferredUsername = 'preferred_username';
  static const profile = 'profile';
  static const picture = 'picture';
  static const website = 'website';
  static const email = 'email';
  static const emailVerified = 'email_verified';
  static const gender = 'gender';
  static const birthdate = 'birthdate';
  static const zoneinfo = 'zoneinfo';
  static const locale = 'locale';
  static const phoneNumber = 'phone_number';
  static const phoneNumberVerified = 'phone_number_verified';
  static const address = 'address';
  static const updatedAt = 'updated_at';

  static List<String> toList() => [
        PublicClaims.sub,
        PublicClaims.name,
        PublicClaims.givenName,
        PublicClaims.familyName,
        PublicClaims.middleName,
        PublicClaims.nickname,
        PublicClaims.preferredUsername,
        PublicClaims.profile,
        PublicClaims.picture,
        PublicClaims.website,
        PublicClaims.email,
        PublicClaims.emailVerified,
        PublicClaims.gender,
        PublicClaims.birthdate,
        PublicClaims.zoneinfo,
        PublicClaims.locale,
        PublicClaims.phoneNumber,
        PublicClaims.phoneNumberVerified,
        PublicClaims.address,
        PublicClaims.updatedAt
      ];
}
