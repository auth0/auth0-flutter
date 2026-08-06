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
  /// token to be returned.
  ///
  /// **Note:** this property will always be `null` on the web platform. The
  /// underlying SDK used does not expose the refresh token for security
  /// reasons.
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

  /// The absolute date and time at which the upstream Identity Provider (IdP)
  /// session expires, when the connection has **"Use ID Token for Session
  /// Expiry"** enabled (`id_token_session_expiry_supported: true`).
  ///
  /// This is derived from the `session_expiry` claim (a Unix-seconds timestamp)
  /// in the ID token and acts as a hard ceiling on the local session,
  /// enforced by the underlying platform SDK:
  ///
  /// - On **iOS**, **macOS** and **Android** the native SDK's credentials
  ///   manager treats the stored credentials as expired once this time is
  ///   reached and will not renew them past it, regardless of [expiresAt].
  /// - On the **web**, `auth0-spa-js` enforces the ceiling on silent renewal:
  ///   once it is reached the SDK stops returning credentials.
  ///
  /// It is layered *on top of* the access-token [expiresAt] and any idle/
  /// absolute timeouts — not a replacement for them.
  ///
  /// This is `null` when the claim is absent (the connection option is not
  /// enabled, or the session predates the feature). A `null` value means
  /// **no ceiling** and must never be treated as an already-expired session.
  ///
  /// [Read more about the IPSIE SL1 `session_expiry` claim](https://openid.github.io/ipsie-openid-sl1/draft-openid-ipsie-sl1-profile.html).
  final DateTime? sessionExpiry;

  Credentials({
    required this.idToken,
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    this.scopes = const {},
    required this.user,
    required this.tokenType,
    this.sessionExpiry,
  });

  factory Credentials.fromMap(final Map<dynamic, dynamic> result) =>
      Credentials(
        idToken: result['idToken'] as String,
        accessToken: result['accessToken'] as String,
        refreshToken: result['refreshToken'] as String?,
        expiresAt: DateTime.parse(result['expiresAt'] as String).toUtc(),
        scopes: Set<String>.from(result['scopes'] as List<Object?>),
        user: UserProfile.fromMap(Map<String, dynamic>.from(
            result['userProfile'] as Map<dynamic, dynamic>)),
        tokenType: result['tokenType'] as String,
        sessionExpiry: _parseSessionExpiry(result['sessionExpiry']),
      );

  Map<String, dynamic> toMap() => {
        'idToken': idToken,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toUtc().toIso8601String(),
        'scopes': scopes.toList(),
        'userProfile': user.toMap(),
        'tokenType': tokenType,
        // Omit the key when there is no ceiling, matching the native
        // serializers rather than carrying an explicit `null`.
        if (sessionExpiry != null)
          'sessionExpiry': sessionExpiry!.toUtc().toIso8601String(),
      };

  /// Parses the `sessionExpiry` value coming across the platform channel.
  ///
  /// Returns `null` when the value is absent, parses an ISO-8601 [String] to a
  /// UTC [DateTime], and throws a [FormatException] for any other type rather
  /// than performing an unchecked cast at the credential boundary.
  static DateTime? _parseSessionExpiry(final Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return DateTime.parse(value).toUtc();
    }
    throw FormatException('Expected an ISO-8601 String for sessionExpiry, '
        'got ${value.runtimeType}');
  }
}
