import '../../credentials.dart';
import '../../request/request_options.dart';

// ignore: comment_references
/// Options used to save [Credentials] using the [CredentialsManagerPlatform].
class SaveCredentialsOptions implements RequestOptions {
  final Credentials credentials;

  SaveCredentialsOptions({required this.credentials});

  @override
  Map<String, dynamic> toMap() => {'credentials': credentials.toMap()};
}
