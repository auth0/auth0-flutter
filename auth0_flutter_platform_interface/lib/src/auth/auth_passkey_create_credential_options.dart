import '../request/request_options.dart';
import 'passkey_login_challenge.dart';

/// Options for presenting the OS passkey UI and creating a login credential.
class AuthPasskeyCreateCredentialOptions implements RequestOptions {
  final PasskeyLoginChallenge challenge;

  AuthPasskeyCreateCredentialOptions({
    required this.challenge,
  });

  @override
  Map<String, dynamic> toMap() => {
        'challenge': challenge.toMap(),
      };
}
