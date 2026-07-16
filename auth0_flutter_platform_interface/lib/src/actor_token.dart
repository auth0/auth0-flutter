/// Represents the acting party in a Custom Token Exchange delegation or
/// impersonation flow (RFC 8693 `actor_token` / `actor_token_type`).
///
/// Providing an [ActorToken] identifies the party acting on behalf of the
/// subject (for example, an AI agent or a support representative). Because both
/// the [token] and its [tokenType] are required, the pair can never be
/// partially supplied.
///
/// When an actor token is used, Auth0 does not issue a refresh token regardless
/// of the requested scopes, and the resulting ID token may contain an `act`
/// claim.
///
/// See also:
/// * [RFC 8693: OAuth 2.0 Token Exchange](https://tools.ietf.org/html/rfc8693)
/// * [Custom Token Exchange Documentation](https://auth0.com/docs/authenticate/custom-token-exchange)
class ActorToken {
  /// The security token representing the acting party.
  final String token;

  /// A URI identifying the type of the [token] (for example,
  /// `urn:ietf:params:oauth:token-type:id_token`, or a custom URI such as
  /// `http://corporate-idp/id-token`).
  final String tokenType;

  const ActorToken({
    required this.token,
    required this.tokenType,
  });
}
