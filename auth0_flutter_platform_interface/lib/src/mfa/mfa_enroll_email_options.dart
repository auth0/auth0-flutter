import '../request/request_options.dart';

/// Options for enrolling a new email-based out-of-band factor.
class MfaEnrollEmailOptions implements RequestOptions {
  /// The `mfa_token` obtained from a `mfa_required` authentication error.
  final String mfaToken;

  /// The email address to enroll and deliver the out-of-band code to.
  final String email;

  MfaEnrollEmailOptions({
    required this.mfaToken,
    required this.email,
  });

  @override
  Map<String, dynamic> toMap() => {
        'mfaToken': mfaToken,
        'email': email,
      };
}
