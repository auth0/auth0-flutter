import '../request/request_options.dart';

/// Options for listing the MFA authenticators enrolled for the user
/// associated with an `mfa_token`.
class MfaGetAuthenticatorsOptions implements RequestOptions {
  /// The `mfa_token` obtained from a `mfa_required` authentication error.
  final String mfaToken;

  /// The allow-list of factor types to return (e.g. `['otp', 'oob']`). Must
  /// contain at least one factor type; the native SDKs reject an empty list
  /// with an `invalid_request` error.
  final List<String> factorsAllowed;

  MfaGetAuthenticatorsOptions({
    required this.mfaToken,
    required this.factorsAllowed,
  });

  @override
  Map<String, dynamic> toMap() => {
        'mfaToken': mfaToken,
        'factorsAllowed': factorsAllowed,
      };
}
