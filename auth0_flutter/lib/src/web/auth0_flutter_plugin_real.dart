import 'dart:async';
import 'dart:html';
import 'dart:js_util';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'auth0_flutter_web_platform_proxy.dart';
import 'extensions/client_options_extensions.dart';
import 'extensions/credentials_extension.dart';
import 'js_interop.dart';

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
        client: Auth0Client(
            _stripNulls(clientOptions.toAuth0ClientOptions(userAgent))));

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

    final authParams = _stripNulls(AuthorizationParams(
        audience: options?.audience,
        redirect_uri: options?.redirectUrl,
        organization: options?.organizationId,
        invitation: options?.invitationUrl,
        max_age: options?.idTokenValidationConfig?.maxAge,
        scope: options?.scopes.isNotEmpty == true
            ? options?.scopes.join(' ')
            : null));

    final loginOptions = RedirectLoginOptions(authorizationParams: authParams);

    return client.loginWithRedirect(loginOptions);
  }

  @override
  Future<Credentials> credentials() async {
    final clientProxy = _ensureClient();
    final options = GetTokenSilentlyOptions(detailedResponse: true);

    final result = await clientProxy.getTokenSilently(options);

    return CredentialsExtension.fromWeb(result);
  }

  @override
  Future<bool> hasValidCredentials() => clientProxy!.isAuthenticated();

  /// Rebuilds the input object, omitting values that are null
  T _stripNulls<T extends Object>(final T obj) {
    final keys = objectKeys(obj);
    final output = newObject<Object>();

    for (var i = 0; i < keys.length; i++) {
      final key = keys[i] as String;
      final value = getProperty(obj, key) as dynamic;

      if (value != null) {
        setProperty(output, key, value);
      }
    }

    return output as T;
  }

  Auth0FlutterWebClientProxy _ensureClient() {
    if (clientProxy == null) {
      throw ArgumentError('Auth0Client has not been initialized');
    }

    return clientProxy!;
  }
}
