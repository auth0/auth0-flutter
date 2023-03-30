import '../../auth0_flutter_platform_interface.dart';

class CredentialsOptions {
  final String? redirectUrl;
  final String? audience;
  final Set<String>? scopes;
  final num? timeoutInSeconds;
  final CacheMode? cacheMode;
  final bool? detailedResponse;
  final Map<String, String> parameters;

  CredentialsOptions(
      {this.redirectUrl,
      this.audience,
      this.scopes,
      this.timeoutInSeconds,
      this.cacheMode,
      this.detailedResponse,
      this.parameters = const {}});
}
