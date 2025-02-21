import 'dart:js_interop';
import 'js_interop.dart';

class Auth0FlutterWebClientProxy {
  final Auth0Client client;

  Auth0FlutterWebClientProxy({required this.client});

  Future<void> loginWithRedirect(final RedirectLoginOptions options) =>
      JSPromiseToFuture(client.loginWithRedirect(options)).toDart;

  Future<void> loginWithPopup(
          [final PopupLoginOptions? options,
          final PopupConfigOptions? config]) =>
      JSPromiseToFuture(client.loginWithPopup(options, config)).toDart;

  Future<void> checkSession() =>
      JSPromiseToFuture(client.checkSession()).toDart;

  Future<WebCredentials> getTokenSilently(
          [final GetTokenSilentlyOptions? options]) =>
      JSPromiseToFuture(client.getTokenSilently(options)).toDart;

  Future<void> handleRedirectCallback() =>
      JSPromiseToFuture(client.handleRedirectCallback()).toDart;

  Future<bool> isAuthenticated() async {
    final jsBool = await JSPromiseToFuture(client.isAuthenticated()).toDart;
    return jsBool.toDart;
  }

  Future<void> logout(final LogoutOptions? options) =>
      JSPromiseToFuture(client.logout(options)).toDart;
}
