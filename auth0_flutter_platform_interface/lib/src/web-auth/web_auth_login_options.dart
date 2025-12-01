import '../login_options.dart';
import 'safari_view_controller.dart';

class WebAuthLoginOptions extends LoginOptions {
  final bool useHTTPS;
  final bool useEphemeralSession;
  final String? scheme;
  final SafariViewController? safariViewController;
  final List<String> allowedBrowsers;

  /// Enables DPoP for token security. Defaults to `false`.
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
