import 'dart:js_util';
import 'js_interop.dart';

class Auth0FlutterWebClientProxy {
  final Auth0Client client;

  Auth0FlutterWebClientProxy({required this.client});

  Future<void> loginWithRedirect(final RedirectLoginOptions options) =>
      promiseToFuture(client.loginWithRedirect(options));

  Future<void> checkSession() => promiseToFuture(client.checkSession());

  Future<WebCredentials> getTokenSilently(
          [final GetTokenSilentlyOptions? options]) =>
      promiseToFuture(client.getTokenSilently(options));

  Future<void> handleRedirectCallback() =>
      promiseToFuture(client.handleRedirectCallback());

  Future<bool> isAuthenticated() => promiseToFuture(client.isAuthenticated());

  Future<void> logout(final LogoutOptions options) =>
      promiseToFuture(client.logout(options));
}
