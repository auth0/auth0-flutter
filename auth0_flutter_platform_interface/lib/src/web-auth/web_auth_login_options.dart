import '../login_options.dart';
import 'safari_view_controller.dart';

class WebAuthLoginOptions extends LoginOptions {
  final bool useEphemeralSession;
  final String? scheme;
  final SafariViewController? safariViewController;

  WebAuthLoginOptions(
      {super.audience,
      super.idTokenValidationConfig,
      super.organizationId,
      super.invitationUrl,
      super.redirectUrl,
      super.scopes,
      super.parameters,
      this.scheme,
      this.useEphemeralSession = false,
      this.safariViewController});

  @override
  Map<String, dynamic> toMap() {
    final map = {
      ...super.toMap(),
      'useEphemeralSession': useEphemeralSession,
      'scheme': scheme,
      ...safariViewController != null
          ? {'safariViewController': safariViewController?.toMap()}
          : <String, dynamic>{}
    };

    return map;
  }
}
