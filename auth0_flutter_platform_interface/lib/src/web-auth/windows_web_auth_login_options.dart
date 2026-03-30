import 'web_auth_login_options.dart';

/// Options for performing PKCE-based login via Universal Login on Windows.
///
/// [appCustomURL] is required. It is the custom-scheme URL (e.g.
/// `auth0flutter://callback`) that the Windows app registers and listens on to
/// receive the OAuth authorization code from the browser.
///
/// [redirectUrl] is optional. When provided, it is used as the `redirect_uri`
/// in the Auth0 authorization URL (e.g. an HTTPS intermediary server). When
/// omitted, [appCustomURL] is used as the `redirect_uri` directly.
class WindowsWebAuthLoginOptions extends WebAuthLoginOptions {
  /// The URL the Windows app listens on to receive the browser redirect.
  ///
  /// Must be a registered custom-scheme URL (e.g. `auth0flutter://callback`).
  /// This is always used as the local activation target regardless of what
  /// [redirectUrl] is set to.
  final String appCustomURL;

  /// How long to wait for the authentication callback before timing out.
  ///
  /// Defaults to 3 minutes. Increase for MFA or slow-network flows.
  final Duration authTimeout;

  WindowsWebAuthLoginOptions({
    required this.appCustomURL,
    this.authTimeout = const Duration(minutes: 3),
    super.audience,
    super.scopes = const {'openid', 'profile', 'email', 'offline_access'},
    super.redirectUrl,
    super.organizationId,
    super.invitationUrl,
    super.parameters = const {},
    super.idTokenValidationConfig,
  });

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'appCustomURL': appCustomURL,
        'authTimeoutSeconds': authTimeout.inSeconds,
      };
}
