import 'dart:convert';
import 'dart:ffi'; // For jsonEncode, jsonDecode (if you implement them)

// Assuming UserIdentity is also a class you'll define in Dart
// If UserIdentity needs to be serializable, it should also have toJson/fromJson.
class UserIdentity {
  // Example properties, adjust based on your actual UserIdentity structure
  final String id;
  final String connection;
  final String provider;
  final bool? isSocial;
  final String? accessToken;
  final String? accessTokenSecret;
  final Map<String, dynamic>? _profileInfo;

  UserIdentity({
    required this.id,
    required this.connection,
    required this.provider,
    this.isSocial,
    this.accessToken,
    this.accessTokenSecret,
    Map<String, dynamic>? profileInfo})
      : _profileInfo = profileInfo ;
  factory UserIdentity.fromJson(final Map<String, dynamic> json)
    => UserIdentity(
      connection: json['connection'] as String,
      id: json['id'] as String,
      isSocial: json['isSocial'] as bool?,
      provider: json['provider'] as String,
      accessToken: json['accessToken'] as String?,
      accessTokenSecret: json['accessTokenSecret'] as String?,
      profileInfo: json['profileInfo'] as Map<String, dynamic>?
    );
}


class UserInfo {
  // Private fields (using _ prefix)
  final String? _id;
  final List<UserIdentity>? _identities;
  final Map<String, dynamic>? _extraInfo; // Using dynamic for Any type
  final Map<String, dynamic>? _userMetadata;
  final Map<String, dynamic>? _appMetadata;

  // Public fields (no special prefix, directly accessible)
  final String? name;
  final String? nickname;
  final String? pictureURL;
  final String? email;
  final bool? isEmailVerified;
  final String? familyName;
  final DateTime? createdAt; // Using DateTime for Date
  final String? givenName;


  UserInfo({
    final String? id, // Private fields can be passed through constructor
    this.name,
    this.nickname,
    this.pictureURL,
    this.email,
    this.isEmailVerified,
    this.familyName,
    this.createdAt,
    final List<UserIdentity>? identities,
    final Map<String, dynamic>? extraInfo,
    final Map<String, dynamic>? userMetadata,
    final Map<String, dynamic>? appMetadata,
    this.givenName,
  })
      : _id = id,
        _identities = identities,
        _extraInfo = extraInfo,
        _userMetadata = userMetadata,
        _appMetadata = appMetadata;

  /// Getter for the unique Identifier of the user. If this represents a Full User Profile (Management API) the 'id' field will be returned.
  /// If the value is not present, it will be considered a User Information and the id will be obtained from the 'sub' claim.
  String? getId() {
    if (_id != null) {
      return _id;
    }
    // Using null-aware operator and type checking for 'sub'
    return (_extraInfo != null && _extraInfo.containsKey('sub'))
        ? _extraInfo['sub'] as String?
        : null;
  }

  Map<String, dynamic> getUserMetadata() =>
      _userMetadata ?? {}; // Return empty map if null

  Map<String, dynamic> getAppMetadata() =>
      _appMetadata ?? {}; // Return empty map if null

  List<UserIdentity> getIdentities() =>
      _identities ?? []; // Return empty list if null

  /// Returns extra information of the profile that is not part of the normalized profile
  ///
  /// @return a map with user's extra information found in the profile
  Map<String, dynamic> getExtraInfo() =>
      // Assuming _extraInfo is already a Map<String, dynamic>
  // If it needed a .toMap() like Kotlin, you'd implement conversion here.
  _extraInfo ?? {}; // Return empty map if null

  // --- Convenience methods for serialization and immutability ---

  // Factory constructor for creating a UserProfile from a JSON map
  factory UserInfo.fromJson(final Map<String, dynamic> json) =>
      UserInfo(
        id: json['id'] as String?,
        name: json['name'] as String?,
        nickname: json['nickname'] as String?,
        pictureURL: json['pictureURL'] as String?,
        email: json['email'] as String?,
        isEmailVerified: json['isEmailVerified'] as bool?,
        familyName: json['familyName'] as String?,
        // Handle date parsing
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        // Handle list of UserIdentity
        identities: (json['identities'] as List<dynamic>?)
            ?.map((e) => UserIdentity.fromJson(e as Map<String, dynamic>))
            .toList(),
        extraInfo: json['extraInfo'] as Map<String, dynamic>?,
        userMetadata: json['userMetadata'] as Map<String, dynamic>?,
        appMetadata: json['appMetadata'] as Map<String, dynamic>?,
        givenName: json['givenName'] as String?,
      );
}
