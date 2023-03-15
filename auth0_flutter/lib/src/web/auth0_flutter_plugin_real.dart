import 'dart:async';
import 'dart:html';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'auth0_flutter_web_platform_proxy.dart';
import 'extensions/client_options_extensions.dart';
import 'extensions/credentials_extension.dart';
import 'extensions/logout_options.extension.dart';
import 'js_interop.dart' as interop;
import 'js_interop_utils.dart';

typedef UrlSearchProvider = String? Function();

class Auth0FlutterPlugin extends Auth0FlutterWebPlatform {
  static void registerWith(final Registrar registrar) {
    Auth0FlutterWebPlatform.instance = Auth0FlutterPlugin();
  }

  Auth0FlutterWebClientProxy? clientProxy;
  UrlSearchProvider urlSearchProvider = () => window.location.search;

  @override
  Future<void> initialize(
      final ClientOptions clientOptions, final UserAgent userAgent) {
    clientProxy ??= Auth0FlutterWebClientProxy(
        client: interop.Auth0Client(JsInteropUtils.stripNulls(
            clientOptions.toAuth0ClientOptions(userAgent))));

    final search = urlSearchProvider();

    if (search?.contains('state=') == true &&
        (search?.contains('code=') == true ||
            search?.contains('error=') == true)) {
      return clientProxy!.handleRedirectCallback();
    }

    return clientProxy!.checkSession();
  }

  @override
  Future<void> loginWithRedirect(final LoginOptions? options) {
    final client = _ensureClient();

    final authParams = JsInteropUtils.stripNulls(interop.AuthorizationParams(
        audience: options?.audience,
        redirect_uri: options?.redirectUrl,
        organization: options?.organizationId,
        invitation: options?.invitationUrl,
        max_age: options?.idTokenValidationConfig?.maxAge,
        scope: options?.scopes.isNotEmpty == true
            ? options?.scopes.join(' ')
            : null));

    final loginOptions =
        interop.RedirectLoginOptions(authorizationParams: authParams);

    return client.loginWithRedirect(loginOptions);
  }

  @override
  Future<Credentials?> loginWithPopup(final PopupLoginOptions? options) async {
    final client = _ensureClient();

    final authParams = JsInteropUtils.stripNulls(interop.AuthorizationParams(
        audience: options?.audience,
        organization: options?.organizationId,
        invitation: options?.invitationUrl,
        max_age: options?.idTokenValidationConfig?.maxAge,
        scope: options?.scopes.isNotEmpty == true
            ? options?.scopes.join(' ')
            : null));

    final popupConfig = JsInteropUtils.stripNulls(interop.PopupConfigOptions(
        popup: options?.popupWindow,
        timeoutInSeconds: options?.timeoutInSeconds));

    await client.loginWithPopup(
        interop.PopupLoginOptions(authorizationParams: authParams),
        popupConfig);

    if (await client.isAuthenticated()) {
      return CredentialsExtension.fromWeb(await client.getTokenSilently(
          interop.GetTokenSilentlyOptions(
              authorizationParams: authParams, detailedResponse: true)));
    }

    return null;
  }

  @override
  Future<void> logout(final LogoutOptions? options) async {
    final client = _ensureClient();
    final logoutOptions = options?.toClientLogoutOptions();

    return client.logout(logoutOptions);
  }

  @override
  Future<Credentials> credentials() async {
    final clientProxy = _ensureClient();
    final options = interop.GetTokenSilentlyOptions(detailedResponse: true);

    final result = await clientProxy.getTokenSilently(options);

    return CredentialsExtension.fromWeb(result);
  }

  @override
  Future<bool> hasValidCredentials() => clientProxy!.isAuthenticated();

  Auth0FlutterWebClientProxy _ensureClient() {
    if (clientProxy == null) {
      throw ArgumentError('Auth0Client has not been initialized');
    }

    return clientProxy!;
  }
}
