import '../auth0_flutter_platform_interface.dart';

/// A collection of authentication artifacts obtained from Auth0 when a user
/// logs in.
class Credentials {
  /// A [JSON web token](https://jwt.io/introduction) that contains the user information.
  ///
  /// **Important**: The [ID tokens](https://auth0.com/docs/security/tokens/id-tokens) obtained from Web Auth login are automatically validated by the underlying native SDK, ensuring their
  /// contents have not been tampered with.
  ///
  /// **This is not the case for the ID tokens obtained when using the
  /// authentication API directly.**
  ///
  /// You must [validate ID tokens](https://auth0.com/docs/security/tokens/id-tokens/validate-id-tokens) received from the Authentication API client before using the information they contain.
  final String idToken;

  /// Token that can be used to make authenticated requests to the specified API
  ///  (the **audience** value used on login).
  ///
  /// ## Futher reading
  /// - [Access tokens](https://auth0.com/docs/security/tokens/access-tokens)
  /// - [Audience](https://auth0.com/docs/secure/tokens/access-tokens/get-access-tokens#control-access-token-audience)
  final String accessToken;

  /// Token that can be used to request a new access token.
  ///
  /// The scope `offline_access` must have been requested on login for a refresh
  ///  token to be returned.
  ///
  /// [Read more about refresh tokens](https://auth0.com/docs/secure/tokens/refresh-tokens).
  final String? refreshToken;

  /// The absolute date and time of when the access token expires.
  final DateTime expiresAt;

  /// The scopes that have been granted by Auth0.
  ///
  /// [Read more about scopes](https://auth0.com/docs/get-started/apis/scopes).
  final Set<String> scopes;

  /// Properties and attributes relating to the authenticated user.
  ///
  /// [Read more about Auth0 User Profiles](https://auth0.com/docs/manage-users/user-accounts/user-profiles)
  final UserProfile user;
  final String tokenType;

  Credentials({
    required this.idToken,
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    this.scopes = const {},
    required this.user,
    required this.tokenType,
  });

  static DateTime parseArabicDate(final String arabicDateString) {
    final String englishDateString = arabicDateString.replaceAllMapped(
      RegExp('[٠١٢٣٤٥٦٧٨٩]'),
      (final match) =>
          String.fromCharCode(match.group(0)!.codeUnitAt(0) - 1632 + 48),
    );

    final DateTime date = DateTime.parse(englishDateString);
    return date;
  }

  factory Credentials.fromMap(final Map<dynamic, dynamic> result) =>
      Credentials(
        idToken: result['idToken'] as String,
        accessToken: result['accessToken'] as String,
        refreshToken: result['refreshToken'] as String?,
        expiresAt: Credentials.parseArabicDate(result['expiresAt'] as String),
        scopes: Set<String>.from(result['scopes'] as List<Object?>),
        user: UserProfile.fromMap(Map<String, dynamic>.from(
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
