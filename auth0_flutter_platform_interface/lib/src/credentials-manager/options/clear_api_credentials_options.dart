import '../../../auth0_flutter_platform_interface.dart';

/// Options used to remove the stored API credentials for a given audience via
/// `CredentialsManagerPlatform.clearApiCredentials()`.
class ClearApiCredentialsOptions implements RequestOptions {
  /// The identifier of the API (the **audience**) whose stored credentials
  /// should be removed.
  final String audience;

  /// The scope the API credentials were stored with, if any.
  ///
  /// **iOS/macOS only.** On Android the stored credentials are keyed by
  /// audience alone, so this value is ignored there.
  final String? scope;

  ClearApiCredentialsOptions({
    required this.audience,
    this.scope,
  });

  @override
  Map<String, dynamic> toMap() => {
        'audience': audience,
        if (scope != null) 'scope': scope,
      };
}
