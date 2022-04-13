class UserIdentity {
  final String id;
  final String connection;
  final String provider;
  final bool isSocial;
  final String? accessToken;
  final String? accessTokenSecret;
  final Map<String, dynamic>? profileInfo;

  const UserIdentity({
    required final this.id,
    required final this.connection,
    required final this.provider,
    required final this.isSocial,
    final this.accessToken,
    final this.accessTokenSecret,
    final this.profileInfo,
  });
}

class UserInfo {
  final String? id;
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

  const UserInfo({
    final this.id,
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

  factory UserInfo.fromMap(final Map<String, dynamic> result) => UserInfo(
        id: result['id'] as String?,
        name: result['name'] as String?,
        givenName: result['givenName'] as String?,
        familyName: result['familyName'] as String?,
        middleName: result['middleName'] as String?,
        nickname: result['nickname'] as String?,
        preferredUsername: result['preferredUsername'] as String?,
        profileURL: result['profileURL'] as String?,
        pictureURL: result['pictureURL'] as String?,
        websiteURL: result['websiteURL'] as String?,
        email: result['email'] as String?,
        isEmailVerified: result['isEmailVerified'] as bool?,
        gender: result['gender'] as String?,
        birthdate: result['birthdate'] as String?,
        zoneinfo: result['zoneinfo'] as String?,
        locale: result['locale'] as String?,
        phoneNumber: result['phoneNumber'] as String?,
        isPhoneNumberVerified: result['isPhoneNumberVerified'] as bool?,
        address: result['address'] != null
            ? Map<String, String>.from(
                result['address'] as Map<dynamic, dynamic>)
            : null,
        updatedAt: result['updatedAt'] != null
            ? DateTime.parse(result['updatedAt'] as String)
            : null,
        customClaims: result['customClaims'] != null
            ? Map<String, dynamic>.from(
                result['customClaims'] as Map<dynamic, dynamic>)
            : null,
      );
}
