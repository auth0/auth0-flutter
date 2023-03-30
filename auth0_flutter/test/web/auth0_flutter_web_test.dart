@Tags(['browser'])

import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:auth0_flutter/src/web/auth0_flutter_plugin_real.dart';
import 'package:auth0_flutter/src/web/auth0_flutter_web_platform_proxy.dart';
import 'package:auth0_flutter/src/web/js_interop.dart' as interop;
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'auth0_flutter_web_test.mocks.dart';

@GenerateMocks([Auth0FlutterWebClientProxy])
void main() {
  final auth0 = Auth0Web('test-domain', 'test-client-id');
  final mockClientProxy = MockAuth0FlutterWebClientProxy();
  final jwtPayload = {'sub': 'auth0:1'};
  final jwt = JWT(jwtPayload).sign(SecretKey('secret'));
  final interop.WebCredentials webCredentials = interop.WebCredentials(
      access_token: jwt,
      id_token: jwt,
      refresh_token: jwt,
      scope: 'openid read_messages',
      expires_in: 0);
  late Auth0FlutterPlugin plugin;

  setUp(() {
    plugin = Auth0FlutterPlugin();
    plugin.clientProxy = mockClientProxy;
    plugin.urlSearchProvider = () => null;
    Auth0FlutterWebPlatform.instance = plugin;
    reset(mockClientProxy);
  });

  test('onLoad is called without authenticated user and no callback', () async {
    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(false));

    final result = await auth0.onLoad();

    expect(result, null);
    verify(mockClientProxy.checkSession());
  });

  test('onLoad is called with an authenticated user and no callback', () async {
    when(mockClientProxy.isAuthenticated()).thenAnswer((final _) async => true);

    when(mockClientProxy.getTokenSilently(any))
        .thenAnswer((final _) => Future.value(webCredentials));

    final result = await auth0.onLoad();

    expect(result?.accessToken, jwt);
    expect(result?.idToken, jwt);
    expect(result?.refreshToken, jwt);
    expect(result?.user.sub, jwtPayload['sub']);
    expect(result?.scopes, {'openid', 'read_messages'});

    verify(mockClientProxy.checkSession());
  });

  test('handleRedirectCallback is called on load when auth params exist in URL',
      () async {
    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(false));

    plugin.urlSearchProvider = () => '?code=abc&state=123';
    await auth0.onLoad();
    verify(mockClientProxy.handleRedirectCallback());
    verifyNever(mockClientProxy.checkSession());
  });

  test('loginWithRedirect with all options', () async {
    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(false));

    await auth0.loginWithRedirect(
        audience: 'http://localhost',
        invitationUrl: 'https://invitation.uri',
        organizationId: 'org-id',
        redirectUrl: 'http://redirect.uri',
        scopes: {'openid', 'read-books'},
        maxAge: 10);

    final params = verify(mockClientProxy.loginWithRedirect(captureAny))
        .captured
        .first
        .authorizationParams;

    expect(params, isNotNull);
    expect(params.audience, 'http://localhost');
    expect(params.invitation, 'https://invitation.uri');
    expect(params.organization, 'org-id');
    expect(params.redirect_uri, 'http://redirect.uri');
    expect(params.scope, 'openid read-books');
    expect(params.max_age, 10);
  });

  test('loginWithRedirect supports custom parameters', () async {
    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(false));

    await auth0.loginWithRedirect(parameters: {'screen_hint': 'signup'});

    final params = verify(mockClientProxy.loginWithRedirect(captureAny))
        .captured
        .first
        .authorizationParams;

    expect(params, isNotNull);
    expect(params.screen_hint, 'signup');
  });

  test('loginWithRedirect strips options that are null', () async {
    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(false));

    await auth0.loginWithRedirect();

    final params = verify(mockClientProxy.loginWithRedirect(captureAny))
        .captured
        .first
        .authorizationParams;

    expect(params, isNotNull);
    expect(params.audience, null);
    expect(params.invitation, null);
    expect(params.organization, null);
    expect(params.redirect_uri, null);
    expect(params.scope, null);
    expect(params.max_age, null);
  });

  test('hasValidCredentials is called without authenticated user', () async {
    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(false));

    final result = await auth0.hasValidCredentials();

    expect(result, false);
  });

  test('hasValidCredentials is called with an authenticated user', () async {
    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(true));

    final result = await auth0.hasValidCredentials();

    expect(result, true);
  });

  test('credentials is called and succeeds', () async {
    when(mockClientProxy.getTokenSilently(any))
        .thenAnswer((final _) => Future.value(webCredentials));

    final result = await auth0.credentials();

    expect(result.accessToken, jwt);
    expect(result.idToken, jwt);
    expect(result.refreshToken, jwt);
    expect(result.user.sub, jwtPayload['sub']);
    expect(result.scopes, {'openid', 'read_messages'});
  });

  test('credentials is called with options and succeeds', () async {
    when(mockClientProxy.getTokenSilently(any))
        .thenAnswer((final _) => Future.value(webCredentials));

    await auth0.credentials(
        redirectUrl: 'http://redirect.url',
        scopes: {'openid', 'profile'},
        audience: 'http://my.api',
        cacheMode: CacheMode.cacheOnly,
        parameters: {'prompt': 'none'},
        timeoutInSeconds: 120);

    final options =
        verify(mockClientProxy.getTokenSilently(captureAny)).captured.first;

    expect(options.authorizationParams.redirect_uri, 'http://redirect.url');
    expect(options.authorizationParams.scope, 'openid profile');
    expect(options.authorizationParams.audience, 'http://my.api');
    expect(options.authorizationParams.prompt, 'none');
    expect(options.cacheMode, 'cache-only');
    expect(options.timeoutInSeconds, 120);
    expect(options.detailedResponse, true);
  });

  test('credentials is called and throws', () async {
    when(mockClientProxy.getTokenSilently(any)).thenThrow(Exception());

    expect(() async => auth0.credentials(), throwsException);
  });

  test('logout is called and succeeds', () async {
    when(mockClientProxy.logout(any)).thenAnswer((final _) => Future.value());
    await auth0.logout(federated: true, returnToUrl: 'http://returnto.url');

    final params =
        verify(mockClientProxy.logout(captureAny)).captured.first.logoutParams;

    expect(params.federated, true);
    expect(params.returnTo, 'http://returnto.url');
  });

  test('logout is called and throws', () async {
    when(mockClientProxy.logout(any)).thenThrow(Exception());

    expect(() async => auth0.logout(), throwsException);
  });

  test('loginWithPopup is called and succeeds', () async {
    when(mockClientProxy.loginWithPopup(any, any))
        .thenAnswer((final _) => Future.value());

    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(true));

    when(mockClientProxy.getTokenSilently(any))
        .thenAnswer((final _) => Future.value(webCredentials));

    final window = Object();

    final credentials = await auth0.loginWithPopup(
        audience: 'http://my.api',
        organizationId: 'org123',
        invitationUrl: 'http://invitation.url',
        scopes: {'openid'},
        maxAge: 20,
        popupWindow: window,
        timeoutInSeconds: 120);

    expect(credentials, isNotNull);

    final capture =
        verify(mockClientProxy.loginWithPopup(captureAny, captureAny)).captured;

    expect(capture.first.authorizationParams.audience, 'http://my.api');
    expect(capture.first.authorizationParams.organization, 'org123');
    expect(
        capture.first.authorizationParams.invitation, 'http://invitation.url');
    expect(capture.first.authorizationParams.scope, 'openid');
    expect(capture.first.authorizationParams.max_age, 20);
    expect(capture.last.popup, window);
    expect(capture.last.timeoutInSeconds, 120);
  });

  test('loginWithPopup is called and throws', () async {
    when(mockClientProxy.loginWithPopup(any, any)).thenThrow(Exception());

    expect(() async => auth0.loginWithPopup(), throwsException);
  });

  test('loginWithPopup supports sending custom parameters', () async {
    when(mockClientProxy.loginWithPopup(any, any))
        .thenAnswer((final _) => Future.value());

    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(true));

    when(mockClientProxy.getTokenSilently(any))
        .thenAnswer((final _) => Future.value(webCredentials));

    final window = Object();

    final credentials =
        await auth0.loginWithPopup(parameters: {'screen_hint': 'signup'});

    expect(credentials, isNotNull);

    final capture =
        verify(mockClientProxy.loginWithPopup(captureAny, captureAny)).captured;

    expect(capture.first.authorizationParams.screen_hint, 'signup');
  });
}
