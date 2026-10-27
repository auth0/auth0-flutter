/// Configuration settings for ID token validation.
class IdTokenValidationConfig {
  /// The value in seconds used to account for clock skew in ID token
  /// expiration. Typically, this value is no more than a minute or two at
  /// maximum.
  ///
  /// Defaults to `60` seconds.
  final int? leeway;

  /// The issuer to be used for validation of the ID token.
  ///
  /// Defaults to the domain used to when calling `Auth0.new`.
  final String? issuer;

  /// Maximum allowable elasped time (in seconds) since authentication.
  /// If the last time the user authenticated is greater than this value, the
  /// user must be reauthenticated.
  ///
  /// Defaults to `0`.
  final int? maxAge;

  /// A one-time random value used to mitigate replay attacks. When provided, it
  /// must match the `nonce` claim in the returned ID token.
  ///
  /// When omitted, the underlying SDK generates and validates a nonce
  /// automatically.
  ///
  /// Not supported on web, where the nonce is always managed internally by
  /// auth0-spa-js.
  final String? nonce;

  const IdTokenValidationConfig(
      {this.leeway, this.issuer, this.maxAge, this.nonce});
}
