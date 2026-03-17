import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'windows_web_authentication_test.mocks.dart';

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

@GenerateMocks([TestPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockedPlatform = MockTestPlatform();

  setUp(() {
    Auth0FlutterWebAuthPlatform.instance = mockedPlatform;
    reset(mockedPlatform);
  });

  group('login', () {
    test('calls the platform to login and returns credentials', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .login(redirectUrl: 'auth0flutter://callback');

      expect(result, TestPlatform.loginResult);
      verify(mockedPlatform.login(any)).called(1);
    });

    test('passes account domain and clientId to the platform', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .login(redirectUrl: 'auth0flutter://callback');

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
    });

    test('passes redirectUrl to the platform', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .login(redirectUrl: 'auth0flutter://callback');

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.options.redirectUrl, 'auth0flutter://callback');
    });

    test('uses default scopes when not specified', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .login(redirectUrl: 'auth0flutter://callback');

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.options.scopes,
          {'openid', 'profile', 'email', 'offline_access'});
    });

    test('uses default authTimeoutSeconds of 180 in parameters', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .login(redirectUrl: 'auth0flutter://callback');

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.options.parameters,
          {'authTimeoutSeconds': '180'});
    });

    test('passes audience to the platform', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .login(
            redirectUrl: 'auth0flutter://callback',
            audience: 'https://my-api.example.com',
          );

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.options.audience, 'https://my-api.example.com');
    });

    test('passes custom scopes to the platform', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .login(
            redirectUrl: 'auth0flutter://callback',
            scopes: {'openid', 'read:messages'},
          );

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.options.scopes, {'openid', 'read:messages'});
    });

    test('passes organizationId and invitationUrl to the platform', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .login(
            redirectUrl: 'auth0flutter://callback',
            organizationId: 'org_123',
            invitationUrl: 'https://invite.example.com',
          );

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.options.organizationId, 'org_123');
      expect(verificationResult.options.invitationUrl,
          'https://invite.example.com');
    });

    test('passes custom authTimeout to the platform', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .login(
            redirectUrl: 'auth0flutter://callback',
            authTimeout: const Duration(seconds: 300),
          );

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.options.parameters,
          {'authTimeoutSeconds': '300'});
    });

    test('typed authTimeout wins over authTimeoutSeconds in parameters',
        () async {
      // When both are provided, the typed authTimeout must take precedence.
      // The reversed spread ensures authTimeoutSeconds is always written last.
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .login(
            redirectUrl: 'auth0flutter://callback',
            authTimeout: const Duration(seconds: 600),
            parameters: {'authTimeoutSeconds': '9999'},
          );

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.options.parameters,
          containsPair('authTimeoutSeconds', '600'));
    });

    test('passes idTokenValidationConfig to the platform', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      const config = IdTokenValidationConfig(
          leeway: 10, maxAge: 3600, issuer: 'https://my-issuer.com');

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .login(
            redirectUrl: 'auth0flutter://callback',
            idTokenValidationConfig: config,
          );

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.options.idTokenValidationConfig, config);
    });

    test('throws UnsupportedError when useDPoP is true', () async {
      // DPoP is not yet implemented on Windows. Passing useDPoP: true must
      // throw UnsupportedError immediately — no platform call should be made.
      expect(
        () => Auth0('test-domain', 'test-clientId')
            .windowsWebAuthentication()
            .login(
              redirectUrl: 'auth0flutter://callback',
              useDPoP: true,
            ),
        throwsUnsupportedError,
      );
      verifyNever(mockedPlatform.login(any));
    });

    test('does not enable DPoP by default', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .login(redirectUrl: 'auth0flutter://callback');

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLoginOptions>;
      expect(verificationResult.options.useDPoP, false);
    });
  });

  group('logout', () {
    test('calls the platform to logout', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async {});

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .logout();

      verify(mockedPlatform.logout(any)).called(1);
    });

    test('passes account domain and clientId to the platform', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async {});

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .logout();

      final verificationResult = verify(mockedPlatform.logout(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLogoutOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
    });

    test('sets federated to false by default', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async {});

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .logout();

      final verificationResult = verify(mockedPlatform.logout(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLogoutOptions>;
      expect(verificationResult.options.federated, false);
    });

    test('passes federated flag to the platform', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async {});

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .logout(federated: true);

      final verificationResult = verify(mockedPlatform.logout(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLogoutOptions>;
      expect(verificationResult.options.federated, true);
    });

    test('uses null returnTo by default', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async {});

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .logout();

      final verificationResult = verify(mockedPlatform.logout(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLogoutOptions>;
      expect(verificationResult.options.returnTo, isNull);
    });

    test('passes returnTo to the platform', () async {
      when(mockedPlatform.logout(any)).thenAnswer((final _) async {});

      await Auth0('test-domain', 'test-clientId')
          .windowsWebAuthentication()
          .logout(returnTo: 'auth0flutter://callback');

      final verificationResult = verify(mockedPlatform.logout(captureAny))
          .captured
          .single as WebAuthRequest<WebAuthLogoutOptions>;
      expect(verificationResult.options.returnTo, 'auth0flutter://callback');
    });
  });

}
