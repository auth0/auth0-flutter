import '../auth/passkey_credential.dart';
import '../request/request_options.dart';
import 'my_account_passkey_enrollment_challenge.dart';

class MyAccountEnrollPasskeyOptions implements RequestOptions {
  final String accessToken;
  final PasskeyEnrollmentChallenge challenge;
  final PasskeyCredential credential;

  MyAccountEnrollPasskeyOptions({
    required this.accessToken,
    required this.challenge,
    required this.credential,
  });

  @override
  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'challenge': challenge.toMap(),
        'credential': credential.toMap(),
      };
}
