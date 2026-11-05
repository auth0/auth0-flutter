/// Whether a profile field can be edited by the user.
enum ProfileFieldAccess {
  readOnly,
  readWrite;

  String toValue() {
    switch (this) {
      case ProfileFieldAccess.readOnly:
        return 'read_only';
      case ProfileFieldAccess.readWrite:
        return 'read_write';
    }
  }

  /// Returns `null` for values unknown to this SDK version.
  static ProfileFieldAccess? fromValue(final String? value) {
    switch (value) {
      case 'read_only':
        return ProfileFieldAccess.readOnly;
      case 'read_write':
        return ProfileFieldAccess.readWrite;
      default:
        return null;
    }
  }
}

/// Where a profile field's value comes from.
enum ProfileFieldSource {
  user,
  idp,
  system;

  String toValue() {
    switch (this) {
      case ProfileFieldSource.user:
        return 'user';
      case ProfileFieldSource.idp:
        return 'idp';
      case ProfileFieldSource.system:
        return 'system';
    }
  }

  /// Returns `null` for values unknown to this SDK version.
  static ProfileFieldSource? fromValue(final String? value) {
    switch (value) {
      case 'user':
        return ProfileFieldSource.user;
      case 'idp':
        return ProfileFieldSource.idp;
      case 'system':
        return ProfileFieldSource.system;
      default:
        return null;
    }
  }
}

/// Describes whether a profile field can be edited by the user and why.
class ProfileFieldPolicy {
  /// Whether the field is editable. `null` if the server returned a value
  /// unknown to this SDK version.
  final ProfileFieldAccess? access;

  /// Where the field's value comes from. `null` if the server returned a
  /// value unknown to this SDK version.
  final ProfileFieldSource? source;

  /// Machine-readable reason a field is read-only, e.g.
  /// `managed_by_identity_provider`. Only set when [access] is
  /// [ProfileFieldAccess.readOnly]. New values may be added by the server.
  final String? reason;

  const ProfileFieldPolicy({this.access, this.source, this.reason});

  factory ProfileFieldPolicy.fromMap(final Map<String, dynamic> result) =>
      ProfileFieldPolicy(
        access: ProfileFieldAccess.fromValue(result['access'] as String?),
        source: ProfileFieldSource.fromValue(result['source'] as String?),
        reason: result['reason'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'access': access?.toValue(),
        'source': source?.toValue(),
        'reason': reason,
      };
}

/// The current user's profile, as returned by the My Account API
/// `/me/v1/profile` endpoint.
///
/// Every property is nullable: the server omits fields that are not set for
/// the user, and any field can be trimmed from the response by using the
/// `fields` parameter of `getUserProfile`.
///
/// [userId], [emailVerified] and [phoneVerified] are read-only: they can't be
/// changed with `updateUserProfile`.
class MyAccountProfile {
  final String? userId;
  final String? givenName;
  final String? familyName;
  final String? name;
  final String? nickname;
  final String? picture;
  final String? email;
  final bool? emailVerified;
  final String? phoneNumber;
  final bool? phoneVerified;
  final String? username;

  /// The ISO 8601 timestamp when the user was created.
  final String? createdAt;

  /// The ISO 8601 timestamp when the user was last updated.
  final String? updatedAt;

  /// Describes, per field, whether it can be edited by the user and why.
  /// Keyed by a JSON Pointer to the field, e.g. `/given_name`.
  ///
  /// `null` when `profile_policy` is not part of the response: when `fields`
  /// is set and does not list `profile_policy`, or when `profile_policy` is
  /// listed with `includeFields: false`.
  final Map<String, ProfileFieldPolicy>? profilePolicy;

  const MyAccountProfile({
    this.userId,
    this.givenName,
    this.familyName,
    this.name,
    this.nickname,
    this.picture,
    this.email,
    this.emailVerified,
    this.phoneNumber,
    this.phoneVerified,
    this.username,
    this.createdAt,
    this.updatedAt,
    this.profilePolicy,
  });

  factory MyAccountProfile.fromMap(final Map<String, dynamic> result) {
    final policy = result['profile_policy'] as Map<dynamic, dynamic>?;

    return MyAccountProfile(
      userId: result['user_id'] as String?,
      givenName: result['given_name'] as String?,
      familyName: result['family_name'] as String?,
      name: result['name'] as String?,
      nickname: result['nickname'] as String?,
      picture: result['picture'] as String?,
      email: result['email'] as String?,
      emailVerified: result['email_verified'] as bool?,
      phoneNumber: result['phone_number'] as String?,
      phoneVerified: result['phone_verified'] as bool?,
      username: result['username'] as String?,
      createdAt: result['created_at'] as String?,
      updatedAt: result['updated_at'] as String?,
      profilePolicy: policy?.map((final key, final value) => MapEntry(
          key as String,
          ProfileFieldPolicy.fromMap(
              Map<String, dynamic>.from(value as Map<dynamic, dynamic>)))),
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'given_name': givenName,
        'family_name': familyName,
        'name': name,
        'nickname': nickname,
        'picture': picture,
        'email': email,
        'email_verified': emailVerified,
        'phone_number': phoneNumber,
        'phone_verified': phoneVerified,
        'username': username,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'profile_policy': profilePolicy
            ?.map((final key, final value) => MapEntry(key, value.toMap())),
      };
}
