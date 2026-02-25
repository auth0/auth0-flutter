/// Authentication artifacts used to establish a web session from a native
/// application context (Native to Web SSO).
///
/// Obtain a [SessionTransferCredentials] instance via
/// `CredentialsManager.ssoCredentials()`.
///
/// The [sessionTransferToken] is:
/// - **Short-lived**: expires after approximately 1 minute
/// - **Single-use**: can only be used once to establish a web session
/// - **Secure**: can be bound to the user's device through IP address or ASN
///
/// Pass the token to your web application as a `session_transfer_token`
/// query parameter, or inject it as a cookie into a WebView. Use it
/// immediately after retrieval.
///
/// **Prerequisites:**
/// - Auth0 Enterprise plan with Native to Web SSO enabled
/// - `offline_access` scope must be present in the stored credentials
///
/// See also: [Auth0 Native to Web SSO documentation](https://auth0.com/docs/authenticate/single-sign-on/native-to-web/configure-implement-native-to-web)
class SessionTransferCredentials {
  /// The session transfer token used to establish an authenticated web session.
  ///
  /// Pass this value to your web application as a `session_transfer_token`
  /// query parameter, or inject it as a cookie into a WebView. The token is
  /// single-use and expires shortly after issuance.
  final String sessionTransferToken;

  /// The token type, typically `"session_transfer"`.
  final String tokenType;

  /// The number of seconds until the [sessionTransferToken] expires.
  final int expiresIn;

  /// A JSON web token containing user identity information.
  final String idToken;

  /// A token that can be used to request new credentials.
  ///
  /// Present only when Refresh Token Rotation (RTR) is enabled and the
  /// `offline_access` scope was requested.
  final String? refreshToken;

  const SessionTransferCredentials({
    required this.sessionTransferToken,
    required this.tokenType,
    required this.expiresIn,
    required this.idToken,
    this.refreshToken,
  });

  factory SessionTransferCredentials.fromMap(
          final Map<dynamic, dynamic> result) =>
      SessionTransferCredentials(
        sessionTransferToken: result['sessionTransferToken'] as String,
        tokenType: result['tokenType'] as String,
        expiresIn: result['expiresIn'] as int,
        idToken: result['idToken'] as String,
        refreshToken: result['refreshToken'] as String?,
      );
}
