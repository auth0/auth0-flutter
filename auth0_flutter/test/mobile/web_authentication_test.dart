import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'web_authentication_test.mocks.dart';

class TestPlatform extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        Auth0FlutterWebAuthPlatform {
  static Credentials loginResult = Credentials.fromMap({
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': DateTime.now().toIso8601String(),
    'scopes': ['a', 'b'],
    'userProfile': {'sub': '123', 'name': 'John Doe'},
    'tokenType': 'Bearer'
  });
}

class TestCMPlatform extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        CredentialsManagerPlatform {}

@GenerateMocks([TestPlatform, TestCMPlatform, CredentialsManager])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockedPlatform = MockTestPlatform();
  final mockedCMPlatform = MockTestCMPlatform();

  setUp(() {
    Auth0FlutterWebAuthPlatform.instance = mockedPlatform;
    CredentialsManagerPlatform.instance = mockedCMPlatform;
    reset(mockedPlatform);
    reset(mockedCMPlatform);
  });

  group('login', () {
    test('calls the platform to login', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);
      when(mockedCMPlatform.saveCredentials(any))
          .thenAnswer((final _) async => true);

      final result = await Auth0('test-domain', 'test-clientId')
          .webAuthentication()
          .login(
              audience: 'test-audience',
              scopes: {'a', 'b'},
              invitationUrl: 'invitation_url',
              organizationId: 'org_123',
              redirectUrl: 'redirect_url',
              useHTTPS: true,
              useEphemeralSession: true,
              safariViewController: const SafariViewController(
                  presentationStyle:
                      SafariViewControllerPresentationStyle.formSheet));

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.audience, 'test-audience');
      expect(verificationResult.options.scopes, {'a', 'b'});
      expect(verificationResult.options.invitationUrl, 'invitation_url');
      expect(verificationResult.options.organizationId, 'org_123');
      expect(verificationResult.options.redirectUrl, 'redirect_url');
      expect(verificationResult.options.useHTTPS, true);
      expect(verificationResult.options.useEphemeralSession, true);
      expect(
          verificationResult.options.safariViewController,
          const SafariViewController(
              presentationStyle:
                  SafariViewControllerPresentationStyle.formSheet));

      expect(result, TestPlatform.loginResult);
    });

    test('saves the credentials on success', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);
      when(mockedCMPlatform.saveCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId').webAuthentication().login();

      final verificationResult =
          verify(mockedCMPlatform.saveCredentials(captureAny)).captured.single
              as CredentialsManagerRequest<SaveCredentialsOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options?.credentials.accessToken,
          TestPlatform.loginResult.accessToken);
    });

    test('does not save the credentials on success when opted out', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);
      when(mockedCMPlatform.saveCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId')
          .webAuthentication(useCredentialsManager: false)
          .login();

      verifyNever(mockedCMPlatform.saveCredentials(any));
    });

    test('uses custom Credentials Manager on success', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);
      when(mockedCMPlatform.saveCredentials(any))
          .thenAnswer((final _) async => true);
      final mockCm = MockCredentialsManager();

      when(mockCm.storeCredentials(any)).thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId', credentialsManager: mockCm)
          .webAuthentication()
          .login();

      // Verify it doesn't call our own Platform Interface when providing a
      // custom CredentialsManager
      verifyNever(mockedCMPlatform.saveCredentials(any));

      final verificationResult = verify(mockCm.storeCredentials(captureAny))
          .captured
          .single as Credentials;

      expect(
          verificationResult.accessToken, TestPlatform.loginResult.accessToken);
    });

    test('set scope and parameters to default value when omitted', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);
      when(mockedCMPlatform.saveCredentials(any))
          .thenAnswer((final _) async => true);

      final result = await Auth0('test-domain', 'test-clientId')
          .webAuthentication()
          .login();

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options.scopes,
          ['openid', 'profile', 'email', 'offline_access']);
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options.parameters, {});
      expect(result, TestPlatform.loginResult);
    });

    test('does not use HTTPS redirect URLs by default', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);
      when(mockedCMPlatform.saveCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId').webAuthentication().login();

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.options.useHTTPS, false);
    });

    test('does not use EphemeralSession by default', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);
      when(mockedCMPlatform.saveCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId').webAuthentication().login();

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.options.useEphemeralSession, false);
    });
  });

  group('logout', () {
    test('passes the federated flag to the platform', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async => {});
      when(mockedCMPlatform.clearCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId')
          .webAuthentication()
          .logout(federated: true);

      final verificationResult = verify(mockedPlatform.logout(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLogoutOptions>;
      expect(verificationResult.options.federated, true);
    });

    test('defaults federated flag to false when omitted', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async => {});
      when(mockedCMPlatform.clearCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId').webAuthentication().logout();

      final verificationResult = verify(mockedPlatform.logout(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLogoutOptions>;
      expect(verificationResult.options.federated, false);
    });
    test('calls the platform to logout', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async => {});
      when(mockedCMPlatform.clearCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId')
          .webAuthentication()
          .logout(useHTTPS: true, returnTo: 'abc');

      final verificationResult = verify(mockedPlatform.logout(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLogoutOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.useHTTPS, true);
      expect(verificationResult.options.returnTo, 'abc');
    });

    test('clears the credentials on success', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async => {});
      when(mockedCMPlatform.clearCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId').webAuthentication().logout();

      final verificationResult =
          verify(mockedCMPlatform.clearCredentials(captureAny)).captured.single
              as CredentialsManagerRequest;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
    });

    test('does not clear the credentials on success when opted out', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);
      when(mockedCMPlatform.clearCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId')
          .webAuthentication(useCredentialsManager: false)
          .logout();

      verifyNever(mockedCMPlatform.clearCredentials(any));
    });

    test('uses custom Credentials Manager on success', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);
      when(mockedCMPlatform.clearCredentials(any))
          .thenAnswer((final _) async => true);
      final mockCm = MockCredentialsManager();
      when(mockCm.clearCredentials()).thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId', credentialsManager: mockCm)
          .webAuthentication()
          .logout();

      // Verify it doesn't call our own Platform Interface when providing a
      //custom CredentialsManager
      verifyNever(mockedCMPlatform.clearCredentials(any));

      verify(mockCm.clearCredentials()).called(1);
    });

    test('passes allowedBrowsers to the platform when specified', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async => {});
      when(mockedCMPlatform.clearCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId').webAuthentication().logout(
          allowedBrowsers: ['com.android.chrome', 'org.mozilla.firefox']);

      final verificationResult = verify(mockedPlatform.logout(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLogoutOptions>;
      expect(verificationResult.options.allowedBrowsers,
          ['com.android.chrome', 'org.mozilla.firefox']);
    });

    test('defaults allowedBrowsers to empty list when not specified', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async => {});
      when(mockedCMPlatform.clearCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId').webAuthentication().logout();

      final verificationResult = verify(mockedPlatform.logout(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLogoutOptions>;
      expect(verificationResult.options.allowedBrowsers, isEmpty);
    });

    test('passes allowedBrowsers with other logout parameters', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async => {});
      when(mockedCMPlatform.clearCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId').webAuthentication().logout(
          useHTTPS: true,
          returnTo: 'https://example.com/logout',
          federated: true,
          allowedBrowsers: ['com.android.chrome']);

      final verificationResult = verify(mockedPlatform.logout(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLogoutOptions>;
      expect(verificationResult.options.useHTTPS, true);
      expect(verificationResult.options.returnTo, 'https://example.com/logout');
      expect(verificationResult.options.federated, true);
      expect(verificationResult.options.allowedBrowsers,
          ['com.android.chrome']);
    });
  });

  group('DPoP Authentication', () {
    group('login with DPoP', () {
      test('passes useDPoP parameter to platform when enabled', () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId')
            .webAuthentication()
            .login(useDPoP: true);

        final verificationResult = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;

        expect(verificationResult.options.useDPoP, true);
        expect(verificationResult.account.domain, 'test-domain');
        expect(verificationResult.account.clientId, 'test-clientId');
      });

      test('passes useDPoP parameter to platform when disabled', () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId')
            .webAuthentication()
            .login();

        final verificationResult = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;

        expect(verificationResult.options.useDPoP, false);
      });

      test('defaults useDPoP to false when not specified', () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId').webAuthentication().login();

        final verificationResult = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;

        expect(verificationResult.options.useDPoP, false);
      });

      test('passes useDPoP with other authentication parameters', () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId').webAuthentication().login(
            useDPoP: true,
            audience: 'test-audience',
            scopes: {'openid', 'profile', 'email'},
            organizationId: 'org_123');

        final verificationResult = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;

        expect(verificationResult.options.useDPoP, true);
        expect(verificationResult.options.audience, 'test-audience');
        expect(
            verificationResult.options.scopes, {'openid', 'profile', 'email'});
        expect(verificationResult.options.organizationId, 'org_123');
      });

      test('saves DPoP credentials to credentials manager on success',
          () async {
        final dpopLoginResult = Credentials.fromMap({
          'accessToken': 'dpop-access-token',
          'idToken': 'dpop-id-token',
          'refreshToken': 'dpop-refresh-token',
          'expiresAt': DateTime.now().toIso8601String(),
          'scopes': ['openid', 'profile'],
          'userProfile': {'sub': '456', 'name': 'DPoP User'},
          'tokenType': 'DPoP'
        });

        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => dpopLoginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        final result = await Auth0('test-domain', 'test-clientId')
            .webAuthentication()
            .login(useDPoP: true);

        final verificationResult =
            verify(mockedCMPlatform.saveCredentials(captureAny)).captured.single
                as CredentialsManagerRequest<SaveCredentialsOptions>;

        expect(verificationResult.options?.credentials.accessToken,
            'dpop-access-token');
        expect(verificationResult.options?.credentials.tokenType, 'DPoP');
        expect(result.tokenType, 'DPoP');
      });

      test(
          'does not save DPoP credentials when credentials manager is disabled',
          () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);

        await Auth0('test-domain', 'test-clientId')
            .webAuthentication(useCredentialsManager: false)
            .login(useDPoP: true);

        verifyNever(mockedCMPlatform.saveCredentials(any));
      });

      test('passes useDPoP with redirectUrl parameter', () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId')
            .webAuthentication()
            .login(useDPoP: true, redirectUrl: 'https://example.com/callback');

        final verificationResult = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;

        expect(verificationResult.options.useDPoP, true);
        expect(verificationResult.options.redirectUrl,
            'https://example.com/callback');
      });

      test('passes useDPoP with useHTTPS parameter', () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId')
            .webAuthentication()
            .login(useDPoP: true, useHTTPS: true);

        final verificationResult = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;

        expect(verificationResult.options.useDPoP, true);
        expect(verificationResult.options.useHTTPS, true);
      });

      test('passes useDPoP with useEphemeralSession parameter', () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId')
            .webAuthentication()
            .login(useDPoP: true, useEphemeralSession: true);

        final verificationResult = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;

        expect(verificationResult.options.useDPoP, true);
        expect(verificationResult.options.useEphemeralSession, true);
      });

      test('passes useDPoP with custom parameters', () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId')
            .webAuthentication()
            .login(useDPoP: true, parameters: {'custom_param': 'custom_value'});

        final verificationResult = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;

        expect(verificationResult.options.useDPoP, true);
        expect(verificationResult.options.parameters,
            {'custom_param': 'custom_value'});
      });

      test('passes useDPoP with invitationUrl parameter', () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId').webAuthentication().login(
            useDPoP: true,
            invitationUrl: 'https://example.com/invite?ticket=abc123');

        final verificationResult = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;

        expect(verificationResult.options.useDPoP, true);
        expect(verificationResult.options.invitationUrl,
            'https://example.com/invite?ticket=abc123');
      });

      test('passes useDPoP with safariViewController parameter (iOS)',
          () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId').webAuthentication().login(
            useDPoP: true,
            safariViewController: const SafariViewController(
                presentationStyle:
                    SafariViewControllerPresentationStyle.fullScreen));

        final verificationResult = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;

        expect(verificationResult.options.useDPoP, true);
        expect(
            verificationResult.options.safariViewController,
            const SafariViewController(
                presentationStyle:
                    SafariViewControllerPresentationStyle.fullScreen));
      });

      test('passes useDPoP with allowedBrowsers parameter (Android)', () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId').webAuthentication().login(
            useDPoP: true,
            allowedBrowsers: ['com.android.chrome', 'org.mozilla.firefox']);

        final verificationResult = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;

        expect(verificationResult.options.useDPoP, true);
        expect(verificationResult.options.allowedBrowsers,
            ['com.android.chrome', 'org.mozilla.firefox']);
      });

      test('uses custom credentials manager with DPoP', () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        final mockCm = MockCredentialsManager();
        when(mockCm.storeCredentials(any)).thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId', credentialsManager: mockCm)
            .webAuthentication()
            .login(useDPoP: true);

        verifyNever(mockedCMPlatform.saveCredentials(any));

        final verificationResult = verify(mockCm.storeCredentials(captureAny))
            .captured
            .single as Credentials;

        expect(verificationResult.accessToken,
            TestPlatform.loginResult.accessToken);

        final loginRequest = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;
        expect(loginRequest.options.useDPoP, true);
      });
    });

    group('DPoP Integration Tests', () {
      test('returns correct credentials with DPoP token type', () async {
        final dpopCredentials = Credentials.fromMap({
          'accessToken': 'dpop-token',
          'idToken': 'id-token',
          'refreshToken': 'refresh-token',
          'expiresAt':
              DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          'scopes': ['openid', 'profile', 'email'],
          'userProfile': {'sub': 'user123', 'name': 'Test User'},
          'tokenType': 'DPoP'
        });

        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => dpopCredentials);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        final result = await Auth0('test-domain', 'test-clientId')
            .webAuthentication()
            .login(useDPoP: true);

        expect(result.accessToken, 'dpop-token');
        expect(result.tokenType, 'DPoP');
        expect(result.user.sub, 'user123');
      });

      test('DPoP works with full authentication flow', () async {
        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => TestPlatform.loginResult);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        final result = await Auth0('test-domain', 'test-clientId')
            .webAuthentication()
            .login(
                useDPoP: true,
                audience: 'https://api.example.com',
                scopes: {'openid', 'profile', 'email', 'offline_access'},
                organizationId: 'org_123',
                redirectUrl: 'myapp://callback',
                useHTTPS: true,
                parameters: {'connection': 'google-oauth2'});

        final verificationResult = verify(mockedPlatform.login(captureAny))
            .captured
            .single as WebAuthRequest<WebAuthLoginOptions>;

        expect(verificationResult.options.useDPoP, true);
        expect(verificationResult.options.audience, 'https://api.example.com');
        expect(verificationResult.options.scopes,
            {'openid', 'profile', 'email', 'offline_access'});
        expect(verificationResult.options.organizationId, 'org_123');
        expect(verificationResult.options.redirectUrl, 'myapp://callback');
        expect(verificationResult.options.useHTTPS, true);
        expect(verificationResult.options.parameters,
            {'connection': 'google-oauth2'});
        expect(result, TestPlatform.loginResult);
      });

      test('DPoP credentials are stored correctly', () async {
        final dpopCredentials = Credentials.fromMap({
          'accessToken': 'dpop-access-token',
          'idToken': 'dpop-id-token',
          'refreshToken': 'dpop-refresh-token',
          'expiresAt':
              DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
          'scopes': ['openid', 'profile', 'email'],
          'userProfile': {'sub': 'dpop-user', 'name': 'DPoP Test'},
          'tokenType': 'DPoP'
        });

        when(mockedPlatform.login(any))
            .thenAnswer((final _) async => dpopCredentials);
        when(mockedCMPlatform.saveCredentials(any))
            .thenAnswer((final _) async => true);

        await Auth0('test-domain', 'test-clientId')
            .webAuthentication()
            .login(useDPoP: true);

        final savedCredentials =
            verify(mockedCMPlatform.saveCredentials(captureAny)).captured.single
                as CredentialsManagerRequest<SaveCredentialsOptions>;

        expect(savedCredentials.options?.credentials.tokenType, 'DPoP');
        expect(savedCredentials.options?.credentials.accessToken,
            'dpop-access-token');
        expect(savedCredentials.account.domain, 'test-domain');
      });
    });
  });
}
