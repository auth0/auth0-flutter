import 'dart:async';
import 'dart:js_interop';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart';

import 'auth0_flutter_web_platform_proxy.dart';
import 'extensions/client_options_extensions.dart';
import 'extensions/credentials_extension.dart';
import 'extensions/credentials_options_extension.dart';
import 'extensions/logout_options.extension.dart';
import 'extensions/web_exception_extensions.dart';
import 'js_interop.dart' as interop;
import 'js_interop_utils.dart';

typedef UrlSearchProvider = String? Function();

class Auth0FlutterPlugin extends Auth0FlutterWebPlatform {
  static void registerWith(final Registrar registrar) {
    Auth0FlutterWebPlatform.instance = Auth0FlutterPlugin();
  }

  Auth0FlutterWebClientProxy? clientProxy;
  UrlSearchProvider urlSearchProvider = () => window.location.search;

  /// The app state that was passed through [loginWithRedirect]
  /// and retrieved in [initialize].
  ///
  /// This object is always a Dart object, never a JS object.
  ///
  /// When the login completes with the redirect, the page is reloaded.
  /// Thus clearing this object is not needed,
  /// as the actual state is managed across reloads,
  /// using the transaction manager.
  // TODO: move the `appState` to the result of `onLoad/initialize`
  Object? _appState;

  @override
  Future<Object?> get appState => Future<Object?>.value(_appState);

  @override
  Future<void> initialize(
      final ClientOptions clientOptions, final UserAgent userAgent) async {
    clientProxy ??= Auth0FlutterWebClientProxy(
        client: interop.Auth0Client(JsInteropUtils.stripNulls(
            clientOptions.toAuth0ClientOptions(userAgent))));

    final search = urlSearchProvider();

    if (search?.contains('state=') == true &&
        (search?.contains('code=') == true ||
            search?.contains('error=') == true)) {
      try {
        final interop.RedirectLoginResult result =
            await clientProxy!.handleRedirectCallback();

        _appState = result.appState.dartify();

        return;
      } catch (e) {
        throw WebExceptionExtension.fromJsObject(JSObject.fromInteropObject(e));
      }
    }

    return clientProxy!.checkSession();
  }

  @override
  Future<void> loginWithRedirect(final LoginOptions? options) {
    final client = _ensureClient();
    final authParams = JsInteropUtils.stripNulls(JsInteropUtils.addCustomParams(
        interop.AuthorizationParams(
            audience: options?.audience,
            redirect_uri: options?.redirectUrl,
            organization: options?.organizationId,
            invitation: options?.invitationUrl,
            max_age: options?.idTokenValidationConfig?.maxAge,
            scope: options?.scopes.isNotEmpty == true
                ? options?.scopes.join(' ')
                : null),
        options?.parameters ?? {}));

    final loginOptions = interop.RedirectLoginOptions(
      appState: options?.appState.jsify(),
      authorizationParams: authParams,
    );

    return client.loginWithRedirect(loginOptions);
  }

  @override
  Future<Credentials> loginWithPopup(final PopupLoginOptions? options) async {
    final client = _ensureClient();

    final authParams = JsInteropUtils.stripNulls(JsInteropUtils.addCustomParams(
        interop.AuthorizationParams(
            audience: options?.audience,
            organization: options?.organizationId,
            invitation: options?.invitationUrl,
            max_age: options?.idTokenValidationConfig?.maxAge,
            scope: options?.scopes.isNotEmpty == true
                ? options?.scopes.join(' ')
                : null),
        options?.parameters ?? {}));

    final popupConfig = JsInteropUtils.stripNulls(interop.PopupConfigOptions(
        popup: options?.popupWindow as JSAny?,
        timeoutInSeconds: options?.timeoutInSeconds));

    try {
      await client.loginWithPopup(
          interop.PopupLoginOptions(authorizationParams: authParams),
          popupConfig);

      return CredentialsExtension.fromWeb(await client.getTokenSilently(
          interop.GetTokenSilentlyOptions(
              authorizationParams: JsInteropUtils.stripNulls(
                  interop.GetTokenSilentlyAuthParams(
                      scope: authParams.scope, audience: authParams.audience)),
              detailedResponse: true)));
    } catch (e) {
      throw WebExceptionExtension.fromJsObject(JSObject.fromInteropObject(e));
    }
  }

  @override
  Future<void> logout(final LogoutOptions? options) async {
    final client = _ensureClient();
    final logoutOptions = options?.toClientLogoutOptions();

    return client.logout(logoutOptions);
  }

  @override
  Future<Credentials> credentials(final CredentialsOptions? options) async {
    final clientProxy = _ensureClient();
    final tokenOptions = options?.toGetTokenSilentlyOptions() ??
        interop.GetTokenSilentlyOptions();
    // Force this, as we always want the full detail back so that we can
    // return a full Credentials instance.
    tokenOptions.detailedResponse = true;
    try {
      final result = await clientProxy.getTokenSilently(tokenOptions);
      return CredentialsExtension.fromWeb(result);
    } catch (e) {
      throw WebExceptionExtension.fromJsObject(JSObject.fromInteropObject(e));
    }
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
