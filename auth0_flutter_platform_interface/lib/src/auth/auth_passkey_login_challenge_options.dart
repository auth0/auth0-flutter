import '../request/request_options.dart';

class AuthPasskeyLoginChallengeOptions implements RequestOptions {
  final String? connection;
  final String? organization;

  AuthPasskeyLoginChallengeOptions({
    this.connection,
    this.organization,
  });

  @override
  Map<String, dynamic> toMap() => {
        'connection': connection,
        'organization': organization,
      };
}
