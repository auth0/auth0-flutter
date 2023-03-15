import '../../auth0_flutter_platform_interface.dart';

class PopupLoginOptions extends LoginOptions {
  final dynamic popupWindow;
  final int? timeoutInSeconds;

  PopupLoginOptions(
      {super.audience,
      super.idTokenValidationConfig,
      super.organizationId,
      super.invitationUrl,
      super.redirectUrl,
      super.scopes,
      super.parameters,
      this.popupWindow,
      this.timeoutInSeconds});
}
