import '../myaccount/phone_type.dart';
import '../request/request_options.dart';

/// Options for enrolling a new phone-based out-of-band factor (SMS or voice).
class MfaEnrollPhoneOptions implements RequestOptions {
  /// The `mfa_token` obtained from a `mfa_required` authentication error.
  final String mfaToken;

  /// The phone number to enroll, in E.164 format (e.g. `+15551234567`).
  final String phoneNumber;

  /// Whether the out-of-band code is delivered via SMS or voice call.
  final PhoneType type;

  MfaEnrollPhoneOptions({
    required this.mfaToken,
    required this.phoneNumber,
    required this.type,
  });

  @override
  Map<String, dynamic> toMap() => {
        'mfaToken': mfaToken,
        'phoneNumber': phoneNumber,
        'type': type.toValue(),
      };
}
