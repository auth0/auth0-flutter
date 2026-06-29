import '../request/request_options.dart';

/// Options for requesting an MFA challenge against an enrolled authenticator.
class MfaChallengeOptions implements RequestOptions {
  /// The `mfa_token` obtained from a `mfa_required` authentication error.
  final String mfaToken;

  /// The identifier of the enrolled authenticator to challenge, as returned
  /// by `getAuthenticators`.
  final String authenticatorId;

  MfaChallengeOptions({
    required this.mfaToken,
    required this.authenticatorId,
  });

  @override
  Map<String, dynamic> toMap() => {
        'mfaToken': mfaToken,
        'authenticatorId': authenticatorId,
      };
}
