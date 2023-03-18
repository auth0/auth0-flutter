import 'cache_mode.dart';

class CredentialsOptions {
  final CacheMode? cacheMode;
  final int? timeoutInSeconds;
  final String? redirectUrl;
  final String? audience;
  final Set<String> scopes;
  final Map<String, String> parameters;

  CredentialsOptions(
      {this.cacheMode,
      this.timeoutInSeconds,
      this.redirectUrl,
      this.audience,
      this.scopes = const {},
      this.parameters = const {}});
}
