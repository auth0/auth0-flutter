import '../../request/request_options.dart';

// ignore: comment_references
/// Options used to retrieve [Credentials] using the
/// `CredentialsManagerPlatform`.
class GetCredentialsOptions implements RequestOptions {
  final int minTtl;
  final Set<String> scopes;
  final Map<String, String> parameters;

  GetCredentialsOptions({
    this.minTtl = 0,
    this.scopes = const {},
    this.parameters = const {},
  });

  @override
  Map<String, dynamic> toMap() => {
        'minTtl': minTtl,
        'scopes': scopes.toList(),
        'parameters': parameters,
      };
}
