import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import '../js_interop.dart';
import '../js_interop_utils.dart';

extension ClientOptionsExtension on ClientOptions {
  Auth0ClientOptions toAuth0ClientOptions(final UserAgent userAgent) =>
      Auth0ClientOptions(
          clientInfo:
              Auth0ClientInfo(name: userAgent.name, version: userAgent.version),
          domain: account.domain,
          clientId: account.clientId,
          authorizeTimeoutInSeconds: authorizeTimeoutInSeconds,
          cacheLocation: cacheLocation?.toString(),
          cookieDomain: cookieDomain,
          issuer: idTokenValidationConfig?.issuer,
          leeway: idTokenValidationConfig?.leeway,
          httpTimeoutInSeconds: httpTimeoutInSeconds,
          legacySameSiteCookie: useLegacySameSiteCookie,
          sessionCheckExpiryDays: sessionCheckExpiryInDays,
          useCookiesForTransactions: useCookiesForTransactions,
          useFormData: useFormData,
          useRefreshTokens: useRefreshTokens,
          useRefreshTokensFallback: useRefreshTokensFallback,
          authorizationParams: JsInteropUtils.stripNulls(
              JsInteropUtils.addCustomParams(
                  AuthorizationParams(
                      audience: audience,
                      scope: scopes?.isNotEmpty == true
                          ? scopes?.join(' ')
                          : null),
                  parameters)));
}
