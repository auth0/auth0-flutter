import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

extension UserProfileExtension on UserProfile {
  static final _registeredClaims = [
    'aud',
    'iss',
    'iat',
    'exp',
    'nbf',
    'nonce',
    'azp',
    'auth_time',
    's_hash',
    'at_hash',
    'c_hash'
  ];

  static final _publicClaims = [
    'sub',
    'name',
    'given_name',
    'family_name',
    'middle_name',
    'nickname',
    'preferred_username',
    'profile',
    'picture',
    'website',
    'email',
    'email_verified',
    'gender',
    'birthdate',
    'zoneinfo',
    'locale',
    'phone_number',
    'phone_number_verified',
    'address',
    'updated_at'
  ];

  static UserProfile fromClaims(final Map<String, dynamic> claims) {
    final customClaims = {...claims};
    final claimsToRemove = [
      ...UserProfileExtension._registeredClaims,
      ...UserProfileExtension._publicClaims
    ];

    for (final key in claimsToRemove) {
      customClaims.remove(key);
    }

    return UserProfile(
      sub: claims['sub'] as String,
      name: claims['name'] as String?,
      givenName: claims['given_name'] as String?,
      familyName: claims['family_name'] as String?,
      middleName: claims['middle_name'] as String?,
      nickname: claims['nickname'] as String?,
      preferredUsername: claims['preferred_username'] as String?,
      profileUrl: claims['profile'] != null
          ? Uri.parse(claims['profile'] as String)
          : null,
      pictureUrl: claims['picture'] != null
          ? Uri.parse(claims['picture'] as String)
          : null,
      websiteUrl: claims['website'] != null
          ? Uri.parse(claims['website'] as String)
          : null,
      email: claims['email'] as String?,
      isEmailVerified: claims['email_verified'] as bool?,
      gender: claims['gender'] as String?,
      birthdate: claims['birthdate'] as String?,
      zoneinfo: claims['zoneinfo'] as String?,
      locale: claims['locale'] as String?,
      phoneNumber: claims['phone_number'] as String?,
      isPhoneNumberVerified: claims['phone_number_verified'] as bool?,
      address: claims['address'] != null
          ? Map<String, String>.from(claims['address'] as Map<dynamic, dynamic>)
          : null,
      updatedAt: claims['updated_at'] != null
          ? DateTime.parse(claims['updated_at'] as String)
          : null,
      customClaims: customClaims.isNotEmpty ? customClaims : null,
    );
  }
}
