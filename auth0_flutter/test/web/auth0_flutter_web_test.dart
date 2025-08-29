@Tags(['browser'])
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:auth0_flutter/src/web/auth0_flutter_plugin_real.dart';
import 'package:auth0_flutter/src/web/auth0_flutter_web_platform_proxy.dart';
import 'package:auth0_flutter/src/web/js_interop.dart' as interop;
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:collection/collection.dart';
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
      expires_in: 0.toJS);
  late Auth0FlutterPlugin plugin;

  setUp(() {
    plugin = Auth0FlutterPlugin();
    plugin.clientProxy = mockClientProxy;
    plugin.urlSearchProvider = () => null;
    Auth0FlutterWebPlatform.instance = plugin;
    reset(mockClientProxy);
  });

  Object createJsException(final String error, final String description) {
    final jsObject = JSObject();
    jsObject.setProperty('error'.toJS, error.toJS);
    jsObject.setProperty('error_description'.toJS, description.toJS);
    return jsObject;
  }

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
        final interop.RedirectLoginResult mockRedirectResult =
        interop.RedirectLoginResult();

        when(mockClientProxy.isAuthenticated())
            .thenAnswer((final _) => Future.value(false));
        when(mockClientProxy.handleRedirectCallback())
            .thenAnswer((final _) => Future.value(mockRedirectResult));

        plugin.urlSearchProvider = () => '?code=abc&state=123';
        await auth0.onLoad();
        verify(mockClientProxy.handleRedirectCallback());
        verifyNever(mockClientProxy.checkSession());
      });

  test('handleRedirectCallback captures appState that was passed', () async {
    final Map<String, Object?> appState = <String, Object?>{
      'someFancyState': 'value',
    };

    final interop.RedirectLoginResult mockRedirectResult =
    interop.RedirectLoginResult(
      appState: appState.jsify(),
    );

    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(false));
    when(mockClientProxy.handleRedirectCallback(any))
        .thenAnswer((final _) => Future.value(mockRedirectResult));

    plugin.urlSearchProvider = () => '?code=abc&state=123';
    await auth0.onLoad();
    verify(mockClientProxy.handleRedirectCallback());
    verifyNever(mockClientProxy.checkSession());

    final Object? capturedAppState = await auth0.appState;

    expect(capturedAppState, isNotNull);
    expect(capturedAppState, isA<Map<Object?, Object?>>());
    capturedAppState as Map<Object?, Object?>;
    const MapEquality<Object?, Object?> eq = MapEquality<Object?, Object?>();

    expect(eq.equals(capturedAppState, appState), isTrue);
  });

  test('appState getter returns value when accessed more than once', () async {
    final Map<String, Object?> appState = <String, Object?>{
      'someFancyState': 'value',
    };

    final interop.RedirectLoginResult mockRedirectResult =
    interop.RedirectLoginResult(
      appState: appState.jsify(),
    );

    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(false));
    when(mockClientProxy.handleRedirectCallback(any))
        .thenAnswer((final _) => Future.value(mockRedirectResult));

    plugin.urlSearchProvider = () => '?code=abc&state=123';
    await auth0.onLoad();
    verify(mockClientProxy.handleRedirectCallback());
    verifyNever(mockClientProxy.checkSession());

    final Object? capturedAppState = await auth0.appState;
    expect(capturedAppState, isNotNull);

    final Object? capturedAppState2 = await auth0.appState;
    expect(capturedAppState2, isNotNull);
  });

  test('onLoad throws the correct exception from handleRedirectCallback',
          () async {
        when(mockClientProxy.isAuthenticated())
            .thenAnswer((final _) => Future.value(false));

        when(mockClientProxy.handleRedirectCallback())
            .thenThrow(createJsException('test', 'test exception'));

        plugin.urlSearchProvider = () => '?code=abc&state=123';

        expect(
                () async => auth0.onLoad(),
            throwsA(predicate((final e) =>
            e is WebException &&
                e.code == 'test' &&
                e.message == 'test exception')));
      });

  test('loginWithRedirect supports appState parameter', () async {
    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(false));

    final Map<String, Object?> appState = <String, Object?>{
      'someFancyState': 'value',
    };

    await auth0.loginWithRedirect(
      appState: appState,
    );

    final params = verify(mockClientProxy.loginWithRedirect(captureAny))
        .captured
        .first as interop.RedirectLoginOptions?;

    final Object? capturedAppState = params?.appState.dartify();

    expect(capturedAppState, isNotNull);
    expect(capturedAppState, isA<Map<Object?, Object?>>());
    capturedAppState as Map<Object?, Object?>;

    const MapEquality<Object?, Object?> eq = MapEquality<Object?, Object?>();

    expect(eq.equals(capturedAppState, appState), isTrue);
  });

  test('loginWithRedirect with all options', () async {
    when(mockClientProxy.isAuthenticated())
        .thenAnswer((final _) => Future.value(false));

    await auth0.loginWithRedirect(
        audience: 'http://localhost',
        invitationUrl: 'https://my-tenant.com/invite?invitation=real-ticket-id',
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
    // Assert that the extracted ticket ID is correct, not the full URL.
    expect(params.invitation, 'real-ticket-id');
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
        scopes: {'openid', 'profile'},
        audience: 'http://my.api',
        cacheMode: CacheMode.cacheOnly,
        parameters: {'prompt': 'none'},
        timeoutInSeconds: 120);

    final options =
        verify(mockClientProxy.getTokenSilently(captureAny)).captured.first;

    expect(options.authorizationParams.scope, 'openid profile');
    expect(options.authorizationParams.audience, 'http://my.api');
    expect(options.authorizationParams.prompt, 'none');
    expect(options.cacheMode, 'cache-only');
    expect(options.timeoutInSeconds, 120);
    expect(options.detailedResponse, true);
  });

  test('credentials is called and throws', () async {
    when(mockClientProxy.getTokenSilently(any))
        .thenThrow(createJsException('test', 'test exception'));

    expect(
            () async => auth0.credentials(),
        throwsA(predicate((final e) =>
        e is WebException &&
            e.code == 'test' &&
            e.message == 'test exception')));
  });

  test('logout is called and succeeds', () async {
    when(mockClientProxy.logout(any)).thenAnswer((final _) => Future.value());
    await auth0.logout(federated: true, returnToUrl: 'http://returnto.url');

    final params =
        verify(mockClientProxy.logout(captureAny)).captured.first.logoutParams;

    expect(params.federated, true);
    expect(params.returnTo, 'http://returnto.url');
  });

  test('loginWithPopup is called and succeeds', () async {
    when(mockClientProxy.loginWithPopup(any, any))
        .thenAnswer((final _) => Future.value());

    when(mockClientProxy.getTokenSilently(any))
        .thenAnswer((final _) => Future.value(webCredentials));

    final window = Object();

    final credentials = await auth0.loginWithPopup(
        audience: 'http://my.api',
        organizationId: 'org123',
        invitationUrl: 'https://my-tenant.com/invite?invitation=real-ticket-id',
        scopes: {'openid'},
        maxAge: 20,
        popupWindow: window,
        timeoutInSeconds: 120);

    expect(credentials, isNotNull);

    final capture =
        verify(mockClientProxy.loginWithPopup(captureAny, captureAny)).captured;

    expect(capture.first.authorizationParams.audience, 'http://my.api');
    expect(capture.first.authorizationParams.organization, 'org123');
    expect(capture.first.authorizationParams.invitation, 'real-ticket-id');
    expect(capture.first.authorizationParams.scope, 'openid');
    expect(capture.first.authorizationParams.max_age, 20);
    expect(capture.last.popup, window);
    expect(capture.last.timeoutInSeconds, 120);
  });

  test('loginWithPopup is called and throws', () async {
    when(mockClientProxy.loginWithPopup(any, any))
        .thenThrow(createJsException('test', 'test exception'));

    expect(() async => auth0.loginWithPopup(), throwsException);
  });

  test('loginWithPopup supports sending custom parameters', () async {
    when(mockClientProxy.loginWithPopup(any, any))
        .thenAnswer((final _) => Future.value());

    when(mockClientProxy.getTokenSilently(any))
        .thenAnswer((final _) => Future.value(webCredentials));

    final credentials =
    await auth0.loginWithPopup(parameters: {'screen_hint': 'signup'});

    expect(credentials, isNotNull);

    final capture =
        verify(mockClientProxy.loginWithPopup(captureAny, captureAny)).captured;

    expect(capture.first.authorizationParams.screen_hint, 'signup');
  });

  test('loginWithPopup throws the correct exception from js.loginWithPopup',
          () async {
        when(mockClientProxy.loginWithPopup(any, any))
            .thenThrow(createJsException('test', 'test exception'));

        expect(
                () async => auth0.loginWithPopup(),
            throwsA(predicate((final e) =>
            e is WebException &&
                e.code == 'test' &&
                e.message == 'test exception')));
      });

  test('loginWithPopup throws the correct exception from getTokenSilently',
          () async {
        when(mockClientProxy.loginWithPopup(any, any))
            .thenAnswer((final _) => Future.value());

        when(mockClientProxy.getTokenSilently(any))
            .thenThrow(createJsException('test', 'test exception'));

        expect(
                () async => auth0.loginWithPopup(),
            throwsA(predicate((final e) =>
            e is WebException &&
                e.code == 'test' &&
                e.message == 'test exception')));
      });

  group('invitationUrl handling', () {
    const fullInvitationUrl =
        'https://my-tenant.auth0.com/login/invitation?invitation=abc-123&organization=org_xyz';
    const invitationId = 'abc-123';
    const invalidUrl = '::not-a-valid-url::';
    const urlWithoutInvitation = 'https://google.com?q=test';

    group('loginWithRedirect', () {
      setUp(() {
        when(mockClientProxy.loginWithRedirect(any))
            .thenAnswer((_) => Future.value());
      });

      test('correctly parses the ticket ID from a full invitation URL',
              () async {
            await auth0.loginWithRedirect(invitationUrl: fullInvitationUrl);

            final captured = verify(mockClientProxy.loginWithRedirect(captureAny))
                .captured
                .single as interop.RedirectLoginOptions;
            expect(captured.authorizationParams!.invitation, invitationId);
          });

      test('correctly uses the ticket ID when it is passed directly',
              () async {
            await auth0.loginWithRedirect(invitationUrl: invitationId);

            final captured = verify(mockClientProxy.loginWithRedirect(captureAny))
                .captured
                .single as interop.RedirectLoginOptions;
            expect(captured.authorizationParams!.invitation, invitationId);
          });

      test('uses the original string as ticket ID when URL parsing fails',
              () async {
            await auth0.loginWithRedirect(invitationUrl: invalidUrl);
            final captured = verify(mockClientProxy.loginWithRedirect(captureAny))
                .captured
                .single as interop.RedirectLoginOptions;
            expect(captured.authorizationParams!.invitation, invalidUrl);
          });

      test(
          'returns null for the ticket when a valid URL without the parameter is passed',
              () async {
            await auth0.loginWithRedirect(invitationUrl: urlWithoutInvitation);

            final captured = verify(mockClientProxy.loginWithRedirect(captureAny))
                .captured
                .single as interop.RedirectLoginOptions;
            expect(captured.authorizationParams!.invitation, isNull);
          });

      test('passes null when invitationUrl is an empty string', () async {
        await auth0.loginWithRedirect(invitationUrl: '');
        final captured = verify(mockClientProxy.loginWithRedirect(captureAny))
            .captured
            .single as interop.RedirectLoginOptions;
        expect(captured.authorizationParams!.invitation, isNull);
      });
    });

    group('loginWithPopup', () {
      setUp(() {
        when(mockClientProxy.loginWithPopup(any, any))
            .thenAnswer((_) => Future.value());
        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((_) => Future.value(webCredentials));
      });

      test('correctly parses the ticket ID from a full invitation URL',
              () async {
            await auth0.loginWithPopup(invitationUrl: fullInvitationUrl);

            final captured =
            verify(mockClientProxy.loginWithPopup(captureAny, any))
                .captured
                .single as interop.PopupLoginOptions;
            expect(captured.authorizationParams!.invitation, invitationId);
          });

      test('correctly uses the ticket ID when it is passed directly',
              () async {
            await auth0.loginWithPopup(invitationUrl: invitationId);

            final captured =
            verify(mockClientProxy.loginWithPopup(captureAny, any))
                .captured
                .single as interop.PopupLoginOptions;
            expect(captured.authorizationParams!.invitation, invitationId);
          });

      test('passes null when invitationUrl is not provided', () async {
        await auth0.loginWithPopup();

        final captured =
        verify(mockClientProxy.loginWithPopup(captureAny, any))
            .captured
            .single as interop.PopupLoginOptions;
        expect(captured.authorizationParams!.invitation, isNull);
      });
    });
  });
}
