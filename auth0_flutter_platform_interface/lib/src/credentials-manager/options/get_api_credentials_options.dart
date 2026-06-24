import '../../../auth0_flutter_platform_interface.dart';

// ignore: comment_references
/// Options used to retrieve [ApiCredentials] via
/// `CredentialsManagerPlatform.getApiCredentials()`.
class GetApiCredentialsOptions implements RequestOptions {
  /// The identifier of the API for which to obtain credentials (the
  /// **audience**), e.g. `https://api.example.com`.
  final String audience;

  /// The scopes to request for the new access token. If empty, the default
  /// scopes configured for the API will be used.
  final Set<String> scopes;

  /// The minimum time-to-live, in seconds, required for the access token. If
  /// the cached token expires sooner, a refresh will be attempted.
  final int minTtl;

  /// Additional parameters to send during the token exchange request.
  final Map<String, String> parameters;

  /// Additional headers to include in the token exchange request.
  final Map<String, String> headers;

  GetApiCredentialsOptions({
    required this.audience,
    this.scopes = const {},
    this.minTtl = 0,
    this.parameters = const {},
    this.headers = const {},
  });

  @override
  Map<String, dynamic> toMap() => {
        'audience': audience,
        'scopes': scopes.toList(),
        'minTtl': minTtl,
        'parameters': parameters,
        'headers': headers,
      };
}
