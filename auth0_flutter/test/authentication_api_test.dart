import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'authentication_api_test.mocks.dart';

class TestPlatform extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        Auth0FlutterAuthPlatform {
  static DatabaseUser signupResult =
      DatabaseUser(email: 'email', isEmailVerified: true);

  static Credentials loginResult = Credentials.fromMap({
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': DateTime.now().toIso8601String(),
    'scopes': ['a', 'b'],
    'userProfile': {'sub': '123', 'name': 'John Doe'},
    'tokenType': 'Bearer'
  });

  static Credentials renewResult = Credentials.fromMap({
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
    Auth0FlutterAuthPlatform.instance = mockedPlatform;
    reset(mockedPlatform);
  });

  group('signup', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.signup(any))
          .thenAnswer((final _) async => TestPlatform.signupResult);

      final result = await Auth0('test-domain', 'test-clientId').api.signup(
        email: 'test-email',
        password: 'test-pass',
        connection: 'test-realm',
        userMetadata: {'test': 'test-123'},
      );

      final verificationResult = verify(mockedPlatform.signup(captureAny))
          .captured
          .single as ApiRequest<AuthSignupOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.email, 'test-email');
      expect(verificationResult.options.password, 'test-pass');
      expect(verificationResult.options.connection, 'test-realm');
      expect(verificationResult.options.userMetadata['test'], 'test-123');
      expect(result, TestPlatform.signupResult);
    });

    test('set userMetadata to default value when omitted', () async {
      when(mockedPlatform.signup(any))
          .thenAnswer((final _) async => TestPlatform.signupResult);

      final result = await Auth0('test-domain', 'test-clientId').api.signup(
            email: 'test-email',
            password: 'test-pass',
            connection: 'test-realm',
          );

      final verificationResult = verify(mockedPlatform.signup(captureAny))
          .captured
          .single as ApiRequest<AuthSignupOptions>;
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options.userMetadata, {});
      expect(result, TestPlatform.signupResult);
    });
  });

  group('login', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      final result = await Auth0('test-domain', 'test-clientId').api.login(
          usernameOrEmail: 'test-user',
          password: 'test-pass',
          connectionOrRealm: 'test-realm',
          audience: 'test-audience',
          scopes: {'test-scope1', 'test-scope2'},
          parameters: {'test': 'test-parameter'});

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as ApiRequest<AuthLoginOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.usernameOrEmail, 'test-user');
      expect(verificationResult.options.password, 'test-pass');
      expect(verificationResult.options.connectionOrRealm, 'test-realm');
      expect(verificationResult.options.audience, 'test-audience');
      expect(verificationResult.options.scopes, {'test-scope1', 'test-scope2'});
      expect(verificationResult.options.parameters['test'], 'test-parameter');
      expect(result, TestPlatform.loginResult);
    });

    test('set scope and parameters to default value when omitted', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      final result = await Auth0('test-domain', 'test-clientId').api.login(
          usernameOrEmail: 'test-user',
          password: 'test-pass',
          connectionOrRealm: 'test-realm');

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as ApiRequest<AuthLoginOptions>;
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options.scopes,
          ['openid', 'profile', 'email', 'offline_access']);
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options.parameters, {});
      expect(result, TestPlatform.loginResult);
    });

    test('set audience to null when omitted', () async {
      when(mockedPlatform.login(any))
          .thenAnswer((final _) async => TestPlatform.loginResult);

      await Auth0('test-domain', 'test-clientId').api.login(
          usernameOrEmail: 'test-user',
          password: 'test-pass',
          connectionOrRealm: 'test-realm');

      final verificationResult = verify(mockedPlatform.login(captureAny))
          .captured
          .single as ApiRequest<AuthLoginOptions>;
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options.audience, null);
    });
  });

  group('resetPassword', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.resetPassword(any)).thenAnswer((final _) async => {});

      await Auth0('test-domain', 'test-clientId').api.resetPassword(
          email: 'test-user',
          connection: 'test-connection',
          parameters: {'test': 'test-parameter'});

      final verificationResult =
          verify(mockedPlatform.resetPassword(captureAny)).captured.single;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.email, 'test-user');
      expect(verificationResult.options.connection, 'test-connection');
      expect(verificationResult.options.parameters['test'], 'test-parameter');
    });

    test('set parameters to default value when omitted', () async {
      when(mockedPlatform.resetPassword(any)).thenAnswer((final _) async => {});

      await Auth0('test-domain', 'test-clientId')
          .api
          .resetPassword(email: 'test-user', connection: 'test-connection');

      final verificationResult =
          verify(mockedPlatform.resetPassword(captureAny)).captured.single;
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options.parameters, {});
    });
  });

  group('renewCredentials', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.renew(any))
          .thenAnswer((final _) async => TestPlatform.renewResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .api
          .renewCredentials(
              refreshToken: 'test-refresh-token',
              scopes: {'test-scope1', 'test-scope2'},
              parameters: {'test': 'test-123'});

      final verificationResult =
          verify(mockedPlatform.renew(captureAny))
          .captured
          .single as ApiRequest<AuthRenewOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options.refreshToken, 'test-refresh-token');
      expect(verificationResult.options.scopes, {'test-scope1', 'test-scope2'});
      expect(verificationResult.options.parameters, {'test': 'test-123'});
      expect(result, TestPlatform.renewResult);
    });

    test('set scope and parameters to default value when omitted', () async {
      when(mockedPlatform.renew(any))
          .thenAnswer((final _) async => TestPlatform.renewResult);

      final result = await Auth0('test-domain', 'test-clientId')
          .api
          .renewCredentials(refreshToken: 'test-refresh-token');

      final verificationResult =
          verify(mockedPlatform.renew(captureAny))
          .captured
          .single as ApiRequest<AuthRenewOptions>;
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options.scopes, []);
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options.parameters, {});
      expect(result, TestPlatform.renewResult);
    });
  });

  group('userInfo', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.userInfo(any))
          .thenAnswer((final _) async => const UserProfile(sub: 'sub'));

      await Auth0('test-domain', 'test-clientId')
          .api
          .userProfile(accessToken: 'test-token');

      final verificationResult =
          verify(mockedPlatform.userInfo(captureAny)).captured.single;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options?.accessToken, 'test-token');
    });

    test('set parameters to default value when omitted', () async {
      when(mockedPlatform.userInfo(any)).thenAnswer((final _) async => const UserProfile(sub: 'sub'));

      await Auth0('test-domain', 'test-clientId')
          .api
          .userProfile(accessToken: 'test-token');

      final verificationResult =
          verify(mockedPlatform.userInfo(captureAny)).captured.single;
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options.parameters, {});
    });
  });
}
