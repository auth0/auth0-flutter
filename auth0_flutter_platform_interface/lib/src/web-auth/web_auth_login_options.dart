import '../login_options.dart';
import 'safari_view_controller.dart';

class WebAuthLoginOptions extends LoginOptions {
  final bool useHTTPS;
  final bool useEphemeralSession;
  final String? scheme;
  final SafariViewController? safariViewController;
  final List<String> allowedBrowsers;

  /// Whether to use Demonstrating Proof-of-Possession (DPoP) for enhanced token security.
  ///
  /// DPoP (defined in [RFC 9449](https://datatracker.ietf.org/doc/html/rfc9449))
  /// is a security mechanism that cryptographically binds access tokens to the
  /// client that requested them. This prevents token theft and replay attacks,
  /// as stolen tokens cannot be used without the client's private key.
  ///
  /// **When to use:**
  /// - Applications requiring enhanced token security
  /// - Environments where token theft is a concern
  /// - APIs configured to require DPoP tokens
  ///
  /// **Platform support:**
  /// - iOS 14+ (requires Auth0.Swift 2.0+)
  /// - macOS 11+ (requires Auth0.Swift 2.0+)
  /// - Android API 24+ (requires Auth0.Android 3.0+)
  /// - Web (requires Auth0 SPA JS SDK 2.0+)
  ///
  /// Defaults to `false`.
  ///
  /// See [Auth0 DPoP Documentation](https://auth0.com/docs/secure/tokens/token-best-practices#use-demonstrating-proof-of-possession-dpop)
  /// for more information.
  final bool useDPoP;

  WebAuthLoginOptions(
      {super.audience,
      super.idTokenValidationConfig,
      super.organizationId,
      super.invitationUrl,
      super.redirectUrl,
      super.scopes,
      super.parameters,
      this.useHTTPS = false,
      this.useEphemeralSession = false,
      this.scheme,
      this.safariViewController,
      this.allowedBrowsers = const [],
      this.useDPoP = false});

  @override
  Map<String, dynamic> toMap() {
    final map = {
      ...super.toMap(),
      'allowedBrowsers': allowedBrowsers,
      'useHTTPS': useHTTPS,
      'useEphemeralSession': useEphemeralSession,
      'scheme': scheme,
      'useDPoP': useDPoP,
      ...safariViewController != null
          ? {'safariViewController': safariViewController?.toMap()}
          : <String, dynamic>{}
    };

    return map;
  }
}
