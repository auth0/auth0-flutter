import '../auth0_flutter_platform_interface.dart';

class Credentials {
  final String idToken;
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final Set<String> scopes;
  final UserProfile userProfile;
  final String tokenType;

  Credentials({
    required this.idToken,
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    this.scopes = const {},
    required this.userProfile,
    required this.tokenType,
  });

  factory Credentials.fromMap(final Map<dynamic, dynamic> result) =>
      Credentials(
        idToken: result['idToken'] as String,
        accessToken: result['accessToken'] as String,
        refreshToken: result['refreshToken'] as String?,
        expiresAt: DateTime.parse(result['expiresAt'] as String),
        scopes: Set<String>.from(result['scopes'] as List<Object?>),
        userProfile: UserProfile.fromMap(Map<String, dynamic>.from(
            result['userProfile'] as Map<dynamic, dynamic>)),
        tokenType: result['tokenType'] as String,
      );

  Map<String, dynamic> toMap() => {
        'idToken': idToken,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
        'scopes': scopes.toList(),
        'tokenType': tokenType,
      };
}
