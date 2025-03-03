import 'dart:js';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../js_interop.dart' as interop;
import '../js_interop_utils.dart';

extension LogoutOptionsExtension on LogoutOptions {
  interop.LogoutOptions toClientLogoutOptions() =>
      JsInteropUtils.stripNulls(interop.LogoutOptions(
        openUrl: openUrl != null ? allowInterop(openUrl!) : null,
        logoutParams: JsInteropUtils.stripNulls(
            interop.LogoutParams(federated: federated, returnTo: returnTo)),
      ));
}
