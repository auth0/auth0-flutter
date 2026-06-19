import '../request/request_options.dart';

/// Options for listing the MFA authenticators enrolled for the user
/// associated with an `mfa_token`.
class MfaGetAuthenticatorsOptions implements RequestOptions {
  /// The `mfa_token` obtained from a `mfa_required` authentication error.
  final String mfaToken;

  /// An optional allow-list of factor types to return. When empty, all
  /// enrolled authenticators are returned.
  final List<String> factorsAllowed;

  MfaGetAuthenticatorsOptions({
    required this.mfaToken,
    this.factorsAllowed = const [],
  });

  @override
  Map<String, dynamic> toMap() => {
        'mfaToken': mfaToken,
        'factorsAllowed': factorsAllowed,
      };
}
