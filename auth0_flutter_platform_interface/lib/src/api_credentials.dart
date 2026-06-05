/// User's credentials obtained from Auth0 for a specific API (audience) as the
/// result of exchanging the stored refresh token using a Multi-Resource Refresh
/// Token (MRRT).
///
/// Obtain an [ApiCredentials] instance via
/// `CredentialsManager.getApiCredentials()`.
///
/// **Prerequisites:**
/// - Multi-Resource Refresh Tokens must be enabled on the tenant.
/// - The `offline_access` scope must be present in the stored credentials so
///   that a refresh token is available for the exchange.
class ApiCredentials {
  /// Token that can be used to make authenticated requests to the API
  /// identified by the requested **audience**.
  ///
  /// [Read more about access tokens](https://auth0.com/docs/secure/tokens/access-tokens).
  final String accessToken;

  /// Indicates how the [accessToken] should be used. For example, as a bearer
  /// token.
  final String tokenType;

  /// The absolute date and time of when the [accessToken] expires.
  final DateTime expiresAt;

  /// The scopes that have been granted by Auth0 for this API.
  ///
  /// [Read more about scopes](https://auth0.com/docs/get-started/apis/scopes).
  final Set<String> scopes;

  const ApiCredentials({
    required this.accessToken,
    required this.tokenType,
    required this.expiresAt,
    this.scopes = const {},
  });

  factory ApiCredentials.fromMap(final Map<dynamic, dynamic> result) =>
      ApiCredentials(
        accessToken: result['accessToken'] as String,
        tokenType: result['tokenType'] as String,
        expiresAt: DateTime.parse(result['expiresAt'] as String).toUtc(),
        scopes: Set<String>.from(result['scopes'] as List<Object?>),
      );

  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'tokenType': tokenType,
        'expiresAt': expiresAt.toUtc().toIso8601String(),
        'scopes': scopes.toList(),
      };
}
