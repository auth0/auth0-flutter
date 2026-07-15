import '../request/request_options.dart';

/// Options for enrolling a new TOTP (authenticator app) factor.
class MfaEnrollTotpOptions implements RequestOptions {
  /// The `mfa_token` obtained from a `mfa_required` authentication error.
  final String mfaToken;

  MfaEnrollTotpOptions({required this.mfaToken});

  @override
  Map<String, dynamic> toMap() => {
        'mfaToken': mfaToken,
      };
}
