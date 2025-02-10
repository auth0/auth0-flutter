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
  });
}
