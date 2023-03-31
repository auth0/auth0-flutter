import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';

import '../js_interop.dart';
import '../js_interop_utils.dart';

extension CredentialsOptionsExtension on CredentialsOptions {
  GetTokenSilentlyOptions toGetTokenSilentlyOptions() =>
      GetTokenSilentlyOptions(
          authorizationParams: JsInteropUtils.stripNulls(
              JsInteropUtils.addCustomParams(
                  GetTokenSilentlyAuthParams(
                      scope: scopes?.join(' '), audience: audience),
                  parameters)),
          cacheMode: cacheMode.toString(),
          timeoutInSeconds: timeoutInSeconds,
          detailedResponse: detailedResponse);
}
