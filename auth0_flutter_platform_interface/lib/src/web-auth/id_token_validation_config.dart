/// Configuration settings for ID token validation.
class IdTokenValidationConfig {
  /// The value in seconds used to account for clock skew in JWT expirations. Typically, this value is no more than a minute or two at maximum. Defaults to 60 seconds.
  final int? leeway;

  /// The issuer to be used for validation of JWTs. Defaults to the domain used to when calling [Auth0.new].
  final String? issuer;

  /// Maximum allowable elasped time (in seconds) since authentication. If the last time the user authenticated is greater than this value, the user must be reauthenticated. Defaults to 0.
  final int? maxAge;

  const IdTokenValidationConfig({this.leeway, this.issuer, this.maxAge});
}
