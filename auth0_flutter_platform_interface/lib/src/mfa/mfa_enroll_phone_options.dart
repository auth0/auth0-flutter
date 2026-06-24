import '../request/request_options.dart';

/// Options for enrolling a new phone-based out-of-band (SMS) factor.
///
/// The native mobile SDKs only support the SMS channel for phone enrollment,
/// so no channel selection is exposed here.
class MfaEnrollPhoneOptions implements RequestOptions {
  /// The `mfa_token` obtained from a `mfa_required` authentication error.
  final String mfaToken;

  /// The phone number to enroll, in E.164 format (e.g. `+15551234567`).
  final String phoneNumber;

  MfaEnrollPhoneOptions({
    required this.mfaToken,
    required this.phoneNumber,
  });

  @override
  Map<String, dynamic> toMap() => {
        'mfaToken': mfaToken,
        'phoneNumber': phoneNumber,
      };
}
