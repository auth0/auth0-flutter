import '../request/request_options.dart';
import 'passkey_challenge.dart';
import 'passkey_credential.dart';
import 'passkey_verification_method.dart';

class AuthPasskeyExchangeOptions implements RequestOptions {
  final PasskeyChallenge challenge;
  final PasskeyCredential credential;
  final String? connection;
  final String? audience;
  final Set<String> scopes;
  final String? organization;
  final Map<String, String> parameters;
  final Map<PasskeyVerificationMethod, String> verification;

  AuthPasskeyExchangeOptions({
    required this.challenge,
    required this.credential,
    this.connection,
    this.audience,
    this.scopes = const {'openid', 'profile', 'email', 'offline_access'},
    this.organization,
    this.parameters = const {},
    this.verification = const {},
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
        'verification': {
          for (final entry in verification.entries) entry.key.value: entry.value
        },
      };
}
