/// Options for custom token exchange on web platforms.
///
/// This class encapsulates the parameters needed to exchange an external
/// token for Auth0 tokens using the OAuth 2.0 Token Exchange flow (RFC 8693).
///
/// **Parameters:**
///
/// * [subjectToken] - The external token to be exchanged (required)
/// * [subjectTokenType] - A URI that indicates the type of the subject token,
/// * [audience] - The API identifier for which the access token is requested (optional)
/// * [scopes] - Set of OAuth scopes to request (optional)
/// * [organizationId] - organization ID or name of the organization to authenticate with (optional)
class ExchangeTokenOptions {
  final String subjectToken;
  final String subjectTokenType;
  final String? audience;
  final Set<String>? scopes;
  final String? organizationId;

  ExchangeTokenOptions({
    required this.subjectToken,
    required this.subjectTokenType,
    this.audience,
    this.scopes,
    this.organizationId,
  });
}
