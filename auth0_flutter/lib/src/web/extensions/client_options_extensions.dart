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
          // MRRT requires refresh tokens, so enabling it forces them on even
          // if `useRefreshTokens` was explicitly set to false. `== true`
          // null-guards the nullable flag (a bare `useMrrt ?` is not a valid
          // bool condition).
          useRefreshTokens: useMrrt == true ? true : useRefreshTokens,
          useRefreshTokensFallback: useRefreshTokensFallback,
          useDpop: useDPoP,
          useMrrt: useMrrt,
          authorizationParams: JsInteropUtils.stripNulls(
              JsInteropUtils.addCustomParams(
                  AuthorizationParams(
                      audience: audience,
                      scope: scopes?.isNotEmpty == true
                          ? scopes?.join(' ')
                          : null),
                  parameters)));
}
