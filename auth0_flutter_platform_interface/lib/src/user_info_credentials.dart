class UserIdentity {
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
final Map<String, dynamic>? profileInfo})
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
final String? _id;
final List<UserIdentity>? _identities;
final Map<String, dynamic>? _extraInfo;
final Map<String, dynamic>? _userMetadata;
final Map<String, dynamic>? _appMetadata;

final String? name;
final String? nickname;
final String? pictureURL;
final String? email;
final bool? isEmailVerified;
final String? familyName;
final DateTime? createdAt;
final String? givenName;


UserInfo({
final String? id,
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

String? getId() {
if (_id != null) {
return _id;
}
return (_extraInfo != null && _extraInfo.containsKey('sub'))
? _extraInfo['sub'] as String?
    : null;
}

Map<String, dynamic> getUserMetadata() =>
_userMetadata ?? {};
Map<String, dynamic> getAppMetadata() =>
_appMetadata ?? {};

List<UserIdentity> getIdentities() =>
_identities ?? [];

Map<String, dynamic> getExtraInfo() =>
_extraInfo ?? {};

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
    ?.map((final e) => UserIdentity.fromJson(e as Map<String, dynamic>))
    .toList(),
extraInfo: Map<String, dynamic>.from(json['extraInfo'] as Map),
userMetadata: Map<String, dynamic>.from(json['userMetadata'] as Map),
appMetadata: Map<String, dynamic>.from(json['appMetadata'] as Map),
givenName: json['givenName'] as String?,
);
}
