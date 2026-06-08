import '../request/request_options.dart';
import 'passkey_signup_challenge.dart';
import 'passkey_signup_credential.dart';

class AuthPasskeySignupOptions implements RequestOptions {
  final PasskeySignupChallenge challenge;
  final PasskeySignupCredential credential;
  final String? connection;
  final String? audience;
  final Set<String> scopes;
  final String? organization;
  final Map<String, String> parameters;

  AuthPasskeySignupOptions({
    required this.challenge,
    required this.credential,
    this.connection,
    this.audience,
    this.scopes = const {'openid', 'profile', 'email', 'offline_access'},
    this.organization,
    this.parameters = const {},
  });

  @override
  Map<String, dynamic> toMap() => {
        'challenge': challenge.toMap(),
        'credential': credential.toMap(),
        'connection': connection,
        'audience': audience,
        'scopes': scopes.toList(),
        'organization': organization,
        'parameters': parameters,
      };
}
