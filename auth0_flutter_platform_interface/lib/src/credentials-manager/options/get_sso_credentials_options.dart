import '../../../auth0_flutter_platform_interface.dart';

// ignore: comment_references
/// Options used to retrieve [SessionTransferCredentials] via
/// `CredentialsManagerPlatform.getSSOCredentials()`.
class GetSSOCredentialsOptions implements RequestOptions {
  /// Additional parameters to include in the SSO credentials request.
  final Map<String, String> parameters;

  /// Additional headers to include in the SSO credentials request.
  final Map<String, String> headers;

  GetSSOCredentialsOptions({
    this.parameters = const {},
    this.headers = const {},
  });

  @override
  Map<String, dynamic> toMap() => {
        'parameters': parameters,
        'headers': headers,
      };
}
