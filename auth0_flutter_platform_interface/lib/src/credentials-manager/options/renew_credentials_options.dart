import '../../../auth0_flutter_platform_interface.dart';

// ignore: comment_references
/// Options to renew [Credentials] using the `CredentialsManagerPlatform`.
class RenewCredentialsOptions implements RequestOptions {
  final Map<String, String> parameters;

  RenewCredentialsOptions({
    this.parameters = const {},
  });

  @override
  Map<String, dynamic> toMap() => {
        'parameters': parameters,
      };
}
