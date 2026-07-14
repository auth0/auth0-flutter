import '../request/request_options.dart';

/// Options for enrolling a new push-notification factor (Guardian app).
class MfaEnrollPushOptions implements RequestOptions {
  /// The `mfa_token` obtained from a `mfa_required` authentication error.
  final String mfaToken;

  MfaEnrollPushOptions({required this.mfaToken});

  @override
  Map<String, dynamic> toMap() => {
        'mfaToken': mfaToken,
      };
}
