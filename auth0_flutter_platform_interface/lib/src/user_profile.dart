class UserProfile {
  final String? sub;
  final String? nickname;
  final String? email;
  final String? familyName;
  final String? givenName;
  final DateTime? updatedAt;
  final bool? isEmailVerified;
  final String? name;
  final String? profileURL;
  final String? pictureURL;
  final String? websiteURL;
  final String? middleName;
  final String? preferredUsername;

  final String? gender;
  final String? birthdate;
  final String? zoneinfo;
  final String? locale;
  final String? phoneNumber;
  final bool? isPhoneNumberVerified;
  final Map<String, String>? address;
  final Map<String, dynamic>? customClaims;

  const UserProfile({
    final this.sub,
    final this.name,
    final this.givenName,
    final this.familyName,
    final this.middleName,
    final this.nickname,
    final this.preferredUsername,
    final this.profileURL,
    final this.pictureURL,
    final this.websiteURL,
    final this.email,
    final this.isEmailVerified,
    final this.gender,
    final this.birthdate,
    final this.zoneinfo,
    final this.locale,
    final this.phoneNumber,
    final this.isPhoneNumberVerified,
    final this.address,
    final this.updatedAt,
    final this.customClaims,
  });

  factory UserProfile.fromMap(final Map<String, dynamic> result) => UserProfile(
        sub: result['sub'] as String?,
        name: result['name'] as String?,
        givenName: result['given_name'] as String?,
        familyName: result['family_name'] as String?,
        middleName: result['middle_name'] as String?,
        nickname: result['nickname'] as String?,
        preferredUsername: result['preferred_username'] as String?,
        profileURL: result['profile'] as String?,
        pictureURL: result['picture'] as String?,
        websiteURL: result['website'] as String?,
        email: result['email'] as String?,
        isEmailVerified: result['email_verified'] as bool?,
        gender: result['gender'] as String?,
        birthdate: result['birthdate'] as String?,
        zoneinfo: result['zoneinfo'] as String?,
        locale: result['locale'] as String?,
        phoneNumber: result['phone_number'] as String?,
        isPhoneNumberVerified: result['phone_number_verified'] as bool?,
        address: result['address'] != null
            ? Map<String, String>.from(
                result['address'] as Map<dynamic, dynamic>)
            : null,
        updatedAt: result['updated_at'] != null
            ? DateTime.parse(result['updated_at'] as String)
            : null,
        customClaims: result['custom_claims'] != null
            ? Map<String, dynamic>.from(
                result['custom_claims'] as Map<dynamic, dynamic>)
            : null,
      );
}
