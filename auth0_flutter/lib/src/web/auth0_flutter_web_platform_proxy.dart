import 'dart:js_util';
import 'js_interop.dart';

class Auth0FlutterWebClientProxy {
  final Auth0Client client;

  Auth0FlutterWebClientProxy({required this.client});

  Future<void> loginWithRedirect(final RedirectLoginOptions options) =>
      promiseToFuture(client.loginWithRedirect(options));

  Future<void> loginWithPopup(
          [final PopupLoginOptions? options,
          final PopupConfigOptions? config]) =>
      promiseToFuture(client.loginWithPopup(options, config));

  Future<void> checkSession() => promiseToFuture(client.checkSession());

  Future<WebCredentials> getTokenSilently(
          [final GetTokenSilentlyOptions? options]) =>
      promiseToFuture(client.getTokenSilently(options));

  Future<RedirectLoginResult> handleRedirectCallback([final String? url]) {
    // Omit the url if it is not provided, so that the default argument is used.
    if (url == null) {
      return promiseToFuture(client.handleRedirectCallback());
    } else {
      return promiseToFuture(client.handleRedirectCallback(url));
    }
  }

  Future<bool> isAuthenticated() => promiseToFuture(client.isAuthenticated());

  Future<void> logout(final LogoutOptions? options) =>
      promiseToFuture(client.logout(options));
}
