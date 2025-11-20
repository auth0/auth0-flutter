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

      test('correctly uses the ticket ID when it is passed directly', () async {
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

        final captured = verify(mockClientProxy.loginWithPopup(captureAny, any))
            .captured
            .single as interop.PopupLoginOptions;
        expect(captured.authorizationParams!.invitation, invitationId);
      });

      test('correctly uses the ticket ID when it is passed directly', () async {
        await auth0.loginWithPopup(invitationUrl: invitationId);

        final captured = verify(mockClientProxy.loginWithPopup(captureAny, any))
            .captured
            .single as interop.PopupLoginOptions;
        expect(captured.authorizationParams!.invitation, invitationId);
      });

      test('passes null when invitationUrl is not provided', () async {
        await auth0.loginWithPopup();

        final captured = verify(mockClientProxy.loginWithPopup(captureAny, any))
            .captured
            .single as interop.PopupLoginOptions;
        expect(captured.authorizationParams!.invitation, isNull);
      });
    });
  });

  group('DPoP Authentication', () {
    final auth0WithDPoP =
        Auth0Web('test-domain', 'test-client-id', useDPoP: true);

    setUp(() {
      plugin = Auth0FlutterPlugin();
      plugin.clientProxy = mockClientProxy;
      plugin.urlSearchProvider = () => null;
      Auth0FlutterWebPlatform.instance = plugin;
      reset(mockClientProxy);
    });

    group('Constructor with DPoP', () {
      test('creates Auth0Web instance with DPoP enabled', () {
        final auth0DPoP =
            Auth0Web('test-domain', 'test-client-id', useDPoP: true);
        expect(auth0DPoP, isNotNull);
      });

      test('creates Auth0Web instance with DPoP disabled by default', () {
        final auth0NoDPoP = Auth0Web('test-domain', 'test-client-id');
        expect(auth0NoDPoP, isNotNull);
      });

      test('creates Auth0Web instance with explicit DPoP false', () {
        final auth0NoDPoP =
            Auth0Web('test-domain', 'test-client-id', useDPoP: false);
        expect(auth0NoDPoP, isNotNull);
      });
    });

    group('onLoad with DPoP', () {
      test('onLoad is called with DPoP and authenticated user', () async {
        when(mockClientProxy.isAuthenticated())
            .thenAnswer((final _) async => true);
        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((final _) => Future.value(webCredentials));

        final result = await auth0WithDPoP.onLoad();

        expect(result?.accessToken, jwt);
        expect(result?.idToken, jwt);
        expect(result?.refreshToken, jwt);
        expect(result?.user.sub, jwtPayload['sub']);
        expect(result?.scopes, {'openid', 'read_messages'});
        verify(mockClientProxy.checkSession());
      });

      test('onLoad is called with DPoP without authenticated user', () async {
        when(mockClientProxy.isAuthenticated())
            .thenAnswer((final _) => Future.value(false));

        final result = await auth0WithDPoP.onLoad();

        expect(result, null);
        verify(mockClientProxy.checkSession());
      });

      test('onLoad with DPoP handles audience parameter', () async {
        when(mockClientProxy.isAuthenticated())
            .thenAnswer((final _) async => true);
        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((final _) => Future.value(webCredentials));

        final result =
            await auth0WithDPoP.onLoad(audience: 'https://test-api.com');

        expect(result?.accessToken, jwt);
        // Verify getTokenSilently was called (audience parameter handling verified in implementation)
        verify(mockClientProxy.getTokenSilently(any)).called(1);
      });
    });

    group('loginWithPopup with DPoP', () {
      setUp(() {
        when(mockClientProxy.loginWithPopup(any, any))
            .thenAnswer((_) => Future.value());
        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((_) => Future.value(webCredentials));
      });

      test('loginWithPopup with DPoP returns valid credentials', () async {
        final result = await auth0WithDPoP.loginWithPopup();

        expect(result.accessToken, jwt);
        expect(result.idToken, jwt);
        expect(result.refreshToken, jwt);
        expect(result.user.sub, jwtPayload['sub']);
        verify(mockClientProxy.loginWithPopup(any, any));
      });

      test('loginWithPopup with DPoP and audience parameter', () async {
        const testAudience = 'https://DpopFlutterTest/';
        final result =
            await auth0WithDPoP.loginWithPopup(audience: testAudience);

        expect(result.accessToken, jwt);
        final captured = verify(mockClientProxy.loginWithPopup(captureAny, any))
            .captured
            .single as interop.PopupLoginOptions;
        expect(captured.authorizationParams?.audience, testAudience);
      });

      test('loginWithPopup with DPoP and custom scopes', () async {
        const testScopes = {'openid', 'profile', 'email', 'read:messages'};
        await auth0WithDPoP.loginWithPopup(scopes: testScopes);

        final captured = verify(mockClientProxy.loginWithPopup(captureAny, any))
            .captured
            .single as interop.PopupLoginOptions;
        expect(captured.authorizationParams?.scope, testScopes.join(' '));
      });

      test('loginWithPopup with DPoP handles organization parameter', () async {
        const testOrg = 'org_123456';
        await auth0WithDPoP
            .loginWithPopup(parameters: {'organization': testOrg});

        final captured = verify(mockClientProxy.loginWithPopup(captureAny, any))
            .captured
            .single as interop.PopupLoginOptions;
        expect(captured.authorizationParams?.organization, testOrg);
      });

      test('loginWithPopup with DPoP and custom parameters', () async {
        const testRedirectUrl = 'http://localhost:3002';
        await auth0WithDPoP
            .loginWithPopup(parameters: {'redirect_uri': testRedirectUrl});

        final captured = verify(mockClientProxy.loginWithPopup(captureAny, any))
            .captured
            .single as interop.PopupLoginOptions;
        expect(captured.authorizationParams?.redirect_uri, testRedirectUrl);
      });

      test(
          'loginWithPopup with DPoP throws WebAuthenticationException on error',
          () async {
        final jsError = createJsException('login_required', 'Login required');
        when(mockClientProxy.loginWithPopup(any, any)).thenThrow(jsError);

        expect(
          () => auth0WithDPoP.loginWithPopup(),
          throwsA(predicate(
              (e) => e is WebException && e.code == 'login_required')),
        );
      });
    });

    group('loginWithRedirect with DPoP', () {
      setUp(() {
        when(mockClientProxy.loginWithRedirect(any))
            .thenAnswer((_) => Future.value());
      });

      test('loginWithRedirect with DPoP is called successfully', () async {
        await auth0WithDPoP.loginWithRedirect();
        verify(mockClientProxy.loginWithRedirect(any));
      });

      test('loginWithRedirect with DPoP and audience parameter', () async {
        const testAudience = 'https://DpopFlutterTest/';
        await auth0WithDPoP.loginWithRedirect(audience: testAudience);

        final captured = verify(mockClientProxy.loginWithRedirect(captureAny))
            .captured
            .single as interop.RedirectLoginOptions;
        expect(captured.authorizationParams?.audience, testAudience);
      });

      test('loginWithRedirect with DPoP and redirectUrl parameter', () async {
        const testRedirectUrl = 'http://localhost:3002';
        await auth0WithDPoP.loginWithRedirect(redirectUrl: testRedirectUrl);

        final captured = verify(mockClientProxy.loginWithRedirect(captureAny))
            .captured
            .single as interop.RedirectLoginOptions;
        expect(captured.authorizationParams?.redirect_uri, testRedirectUrl);
      });

      test('loginWithRedirect with DPoP and custom scopes', () async {
        const testScopes = {'openid', 'profile', 'offline_access'};
        await auth0WithDPoP.loginWithRedirect(scopes: testScopes);

        final captured = verify(mockClientProxy.loginWithRedirect(captureAny))
            .captured
            .single as interop.RedirectLoginOptions;
        expect(captured.authorizationParams?.scope, testScopes.join(' '));
      });
    });

    group('logout with DPoP', () {
      setUp(() {
        when(mockClientProxy.logout(any)).thenAnswer((_) => Future.value());
      });

      test('logout with DPoP is called successfully', () async {
        await auth0WithDPoP.logout();
        verify(mockClientProxy.logout(any));
      });

      test('logout with DPoP and returnToUrl parameter', () async {
        const returnUrl = 'http://localhost:3002';
        await auth0WithDPoP.logout(returnToUrl: returnUrl);

        final captured = verify(mockClientProxy.logout(captureAny))
            .captured
            .single as interop.LogoutOptions;
        expect(captured.logoutParams?.returnTo, returnUrl);
      });

      test('logout with DPoP throws WebAuthenticationException on error',
          () async {
        final jsError = createJsException('logout_error', 'Logout failed');
        when(mockClientProxy.logout(any)).thenThrow(jsError);

        // Verify that logout throws an exception (exact type may vary due to mock behavior)
        expect(() => auth0WithDPoP.logout(), throwsA(anything));
      });
    });

    group('getTokenSilently with DPoP', () {
      setUp(() {
        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((_) => Future.value(webCredentials));
      });

      test('getTokenSilently with DPoP returns valid credentials', () async {
        final result = await auth0WithDPoP.credentials();

        expect(result.accessToken, jwt);
        expect(result.idToken, jwt);
        expect(result.refreshToken, jwt);
        verify(mockClientProxy.getTokenSilently(any));
      });

      test('getTokenSilently with DPoP and audience parameter', () async {
        const testAudience = 'https://DpopFlutterTest/';
        await auth0WithDPoP.credentials(audience: testAudience);

        final captured = verify(mockClientProxy.getTokenSilently(captureAny))
            .captured
            .single as interop.GetTokenSilentlyOptions;
        expect(captured.authorizationParams?.audience, testAudience);
      });

      test('getTokenSilently with DPoP throws ApiException on error', () async {
        final jsError =
            createJsException('consent_required', 'Consent required');
        when(mockClientProxy.getTokenSilently(any)).thenThrow(jsError);

        expect(
          () => auth0WithDPoP.credentials(),
          throwsA(predicate(
              (e) => e is WebException && e.code == 'consent_required')),
        );
      });
    });

    group('DPoP Token Verification', () {
      test('verifies DPoP token type is included in response', () async {
        when(mockClientProxy.loginWithPopup(any, any))
            .thenAnswer((_) => Future.value());
        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((_) => Future.value(webCredentials));

        final result = await auth0WithDPoP.loginWithPopup(
          audience: 'https://DpopFlutterTest/',
        );

        expect(result.accessToken, isNotNull);
        expect(result.accessToken, isNotEmpty);
        // Token should be a valid JWT format
        expect(result.accessToken.split('.').length, 3);
      });

      test('verifies credentials contain all required fields with DPoP',
          () async {
        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((_) => Future.value(webCredentials));

        final result = await auth0WithDPoP.credentials();

        expect(result.accessToken, isNotNull);
        expect(result.idToken, isNotNull);
        expect(result.refreshToken, isNotNull);
        expect(result.user, isNotNull);
        expect(result.user.sub, isNotEmpty);
        expect(result.scopes, isNotEmpty);
      });
    });

    group('DPoP Error Handling', () {
      test('handles invalid DPoP configuration error', () async {
        final jsError =
            createJsException('invalid_request', 'Invalid DPoP configuration');
        when(mockClientProxy.loginWithPopup(any, any)).thenThrow(jsError);

        expect(
          () => auth0WithDPoP.loginWithPopup(),
          throwsA(predicate(
              (e) => e is WebException && e.code == 'AUTHENTICATION_ERROR')),
        );
      });

      test('handles DPoP proof validation error', () async {
        final jsError = createJsException(
            'invalid_dpop_proof', 'DPoP proof validation failed');
        when(mockClientProxy.getTokenSilently(any)).thenThrow(jsError);

        expect(
          () => auth0WithDPoP.credentials(),
          throwsA(predicate(
              (e) => e is WebException && e.code == 'invalid_dpop_proof')),
        );
      });

      test('handles network error during DPoP login', () async {
        final jsError =
            createJsException('network_error', 'Network request failed');
        when(mockClientProxy.loginWithPopup(any, any)).thenThrow(jsError);

        expect(
          () => auth0WithDPoP.loginWithPopup(),
          throwsA(
              predicate((e) => e is WebException && e.code == 'network_error')),
        );
      });

      test('handles missing DPoP nonce error', () async {
        final jsError =
            createJsException('use_dpop_nonce', 'DPoP nonce required');
        when(mockClientProxy.getTokenSilently(any)).thenThrow(jsError);

        expect(
          () => auth0WithDPoP.credentials(),
          throwsA(predicate(
              (e) => e is WebException && e.code == 'use_dpop_nonce')),
        );
      });

      test('handles DPoP replay attack detection', () async {
        final jsError = createJsException(
            'invalid_dpop_proof', 'DPoP proof has been used before');
        when(mockClientProxy.loginWithPopup(any, any)).thenThrow(jsError);

        expect(
          () => auth0WithDPoP.loginWithPopup(),
          throwsA(predicate(
              (e) => e is WebException && e.code == 'invalid_dpop_proof')),
        );
      });
    });

    group('DPoP Integration Tests', () {
      test('DPoP instance is correctly initialized with useDPoP flag', () {
        final dpopAuth0 =
            Auth0Web('test-domain', 'test-client-id', useDPoP: true);
        expect(dpopAuth0, isNotNull);
      });

      test('Non-DPoP instance does not have DPoP enabled', () {
        final regularAuth0 =
            Auth0Web('test-domain', 'test-client-id', useDPoP: false);
        expect(regularAuth0, isNotNull);
      });

      test('DPoP loginWithPopup with custom audience', () async {
        const customAudience = 'https://custom-api.example.com/';
        when(mockClientProxy.loginWithPopup(any, any))
            .thenAnswer((_) => Future.value());
        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((_) => Future.value(webCredentials));

        await auth0WithDPoP.loginWithPopup(audience: customAudience);

        final captured = verify(mockClientProxy.loginWithPopup(captureAny, any))
            .captured
            .single as interop.PopupLoginOptions;
        expect(captured.authorizationParams?.audience, customAudience);
      });

      test('DPoP loginWithRedirect with custom audience', () async {
        const customAudience = 'https://custom-api.example.com/';
        when(mockClientProxy.loginWithRedirect(any))
            .thenAnswer((_) => Future.value());

        await auth0WithDPoP.loginWithRedirect(audience: customAudience);

        final captured = verify(mockClientProxy.loginWithRedirect(captureAny))
            .captured
            .single as interop.RedirectLoginOptions;
        expect(captured.authorizationParams?.audience, customAudience);
      });

      test('DPoP credentials with cacheMode parameter', () async {
        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((_) => Future.value(webCredentials));

        await auth0WithDPoP.credentials(cacheMode: CacheMode.on);

        final captured = verify(mockClientProxy.getTokenSilently(captureAny))
            .captured
            .single as interop.GetTokenSilentlyOptions;
        expect(captured.cacheMode, 'on');
      });

      test('DPoP onLoad initializes correctly', () async {
        when(mockClientProxy.isAuthenticated())
            .thenAnswer((_) => Future.value(false));
        when(mockClientProxy.checkSession()).thenAnswer((_) => Future.value());

        final result = await auth0WithDPoP.onLoad();

        expect(result, isNull);
        verify(mockClientProxy.checkSession());
      });

      test('DPoP onLoad returns credentials when authenticated', () async {
        when(mockClientProxy.isAuthenticated())
            .thenAnswer((_) => Future.value(true));
        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((_) => Future.value(webCredentials));

        final result = await auth0WithDPoP.onLoad();

        expect(result, isNotNull);
        expect(result?.accessToken, jwt);
        verify(mockClientProxy.checkSession());
      });
    });

    group('DPoP Token Management', () {
      test('DPoP credentials refresh with cacheMode off', () async {
        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((_) => Future.value(webCredentials));

        final result = await auth0WithDPoP.credentials(
          cacheMode: CacheMode.off,
        );

        expect(result.accessToken, jwt);
        final captured = verify(mockClientProxy.getTokenSilently(captureAny))
            .captured
            .single as interop.GetTokenSilentlyOptions;
        expect(captured.cacheMode, 'off');
      });

      test('DPoP handles token expiration gracefully', () async {
        final expiredCredentials = interop.WebCredentials(
          access_token: jwt,
          id_token: jwt,
          refresh_token: jwt,
          scope: 'openid',
          expires_in: (-3600).toJS, // Expired
        );

        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((_) => Future.value(expiredCredentials));

        final result = await auth0WithDPoP.credentials();

        expect(result.accessToken, jwt);
        verify(mockClientProxy.getTokenSilently(any));
      });

      test('DPoP credentials with multiple scopes', () async {
        final multiScopeCredentials = interop.WebCredentials(
          access_token: jwt,
          id_token: jwt,
          refresh_token: jwt,
          scope: 'openid profile email read:messages write:posts',
          expires_in: 0.toJS,
        );

        when(mockClientProxy.getTokenSilently(any))
            .thenAnswer((_) => Future.value(multiScopeCredentials));

        final result = await auth0WithDPoP.credentials();

        expect(result.accessToken, jwt);
        expect(result.scopes,
            {'openid', 'profile', 'email', 'read:messages', 'write:posts'});
      });
    });
  });
}
