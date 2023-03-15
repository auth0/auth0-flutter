import '../../auth0_flutter_platform_interface.dart';

class PopupLoginOptions extends LoginOptions {
  final dynamic popup;
  final int? timeoutInSeconds;

  PopupLoginOptions(
      {super.audience,
      super.idTokenValidationConfig,
      super.organizationId,
      super.invitationUrl,
      super.redirectUrl,
      super.scopes,
      super.parameters,
      this.popup,
      this.timeoutInSeconds});
}
