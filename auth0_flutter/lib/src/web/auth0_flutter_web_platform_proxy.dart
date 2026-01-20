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

  Future<WebCredentials> exchangeToken(final ExchangeTokenOptions options) =>
      JSPromiseToFuture(client.exchangeToken(options)).toDart;

  Future<RedirectLoginResult> handleRedirectCallback([final String? url]) {
    // Omit the url if it is not provided, so that the default argument is used.
    if (url == null) {
      return JSPromiseToFuture(client.handleRedirectCallback()).toDart;
    } else {
      return JSPromiseToFuture(client.handleRedirectCallback(url.toJS)).toDart;
    }
  }

  Future<bool> isAuthenticated() async {
    final jsBool = await JSPromiseToFuture(client.isAuthenticated()).toDart;
    return jsBool.toDart;
  }

  Future<void> logout(final LogoutOptions? options) =>
      JSPromiseToFuture(client.logout(options)).toDart;
}
