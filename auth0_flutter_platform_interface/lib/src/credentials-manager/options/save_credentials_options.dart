
import '../../credentials.dart';
import '../../request/request_options.dart';

class SaveCredentialsOptions implements RequestOptions {
  final Credentials credentials;

  SaveCredentialsOptions({required this.credentials});

  @override
  Map<String, dynamic> toMap() => {'credentials': credentials.toMap()};
}
