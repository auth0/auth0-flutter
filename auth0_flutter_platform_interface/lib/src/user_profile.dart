/// A collection of properties that represents the authenticated user, extracted
///  from ID token claims.
class UserProfile {
  /// The Auth0 user identifier.
  final String sub;

  /// The nickname of the user.
  ///
  /// Requires the `profile` scope.
  final String? nickname;

  /// The email of the user.
  ///
  /// Requires the `email` scope.
  final String? email;

  /// The last name of the user.
  ///
  /// Requires the `profile` scope.
  final String? familyName;

  /// The first name of the user.
  ///
  /// Requires the `profile` scope.
  final String? givenName;

  /// The date and time the user's information was last updated.
  ///
  /// Requires the `profile` scope.
  final DateTime? updatedAt;

  /// If the user's email is verified.
  ///
  /// Requires the `email` scope.
  final bool? isEmailVerified;

  /// The name of the user.
  ///
  /// Requires the `profile` scope.
  final String? name;

  /// The URL of the user's profile page.
  ///
  /// Requires the `profile` scope.
  final Uri? profileUrl;

  /// The URL of the user's picture.
  ///
  /// Requires the `profile` scope.
  final Uri? pictureUrl;

  /// The URL of the user's website.
  ///
  /// Requires the `profile` scope.
  final Uri? websiteUrl;

  /// The middle name of the user.
  ///
  /// Requires the `profile` scope.
  final String? middleName;

  /// The preferred username of the user.
  ///
  /// Requires the `profile` scope.
  final String? preferredUsername;

  /// The gender of the user.
  ///
  /// Requires the `profile` scope.
  final String? gender;

  /// The birthdate of the user.
  ///
  /// Requires the `profile` scope.
  final String? birthdate;

  /// The time zone of the user.
  ///
  /// Requires the `profile` scope.
  final String? zoneinfo;

  /// The locale of the user.
  ///
  /// Requires the `profile` scope.
  final String? locale;

  /// The phone number of the user.
  ///
  /// Requires the `phone` scope.
  final String? phoneNumber;

  /// If the user's phone number is verified.
  ///
  /// Requires the `phone` scope.
  final bool? isPhoneNumberVerified;

  /// The address of the user.
  ///
  /// Requires the `address` scope.
  final Map<String, String>? address;

  /// Any custom claims
  final Map<String, dynamic>? customClaims;

  const UserProfile({
    required this.sub,
    this.name,
    this.givenName,
    this.familyName,
    this.middleName,
    this.nickname,
    this.preferredUsername,
    this.profileUrl,
    this.pictureUrl,
    this.websiteUrl,
    this.email,
    this.isEmailVerified,
    this.gender,
    this.birthdate,
    this.zoneinfo,
    this.locale,
    this.phoneNumber,
    this.isPhoneNumberVerified,
    this.address,
    this.updatedAt,
    this.customClaims,
  });

  factory UserProfile.fromMap(final Map<String, dynamic> result) => UserProfile(
        sub: result['sub'] as String,
        name: result['name'] as String?,
        givenName: result['given_name'] as String?,
        familyName: result['family_name'] as String?,
        middleName: result['middle_name'] as String?,
        nickname: result['nickname'] as String?,
        preferredUsername: result['preferred_username'] as String?,
        profileUrl: result['profile'] != null
            ? Uri.parse(result['profile'] as String)
            : null,
        pictureUrl: result['picture'] != null
            ? Uri.parse(result['picture'] as String)
            : null,
        websiteUrl: result['website'] != null
            ? Uri.parse(result['website'] as String)
            : null,
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

  Map<String, dynamic> toMap() => {
        'sub': sub,
        'name': name,
        'given_name': givenName,
        'family_name': familyName,
        'middle_name': middleName,
        'nickname': nickname,
        'preferred_username': preferredUsername,
        'profile': profileUrl?.toString(),
        'picture': pictureUrl?.toString(),
        'website': websiteUrl?.toString(),
        'email': email,
        'email_verified': isEmailVerified,
        'gender': gender,
        'birthdate': birthdate,
        'zoneinfo': zoneinfo,
        'locale': locale,
        'phone_number': phoneNumber,
        'phone_number_verified': isPhoneNumberVerified,
        'address': address,
        'updated_at': updatedAt?.toIso8601String(),
        'custom_claims': customClaims,
      };
}
