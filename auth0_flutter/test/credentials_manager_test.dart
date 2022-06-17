import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'credentials_manager_test.mocks.dart';

class TestPlatform extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        CredentialsManagerPlatform {
  static Credentials credentials = Credentials.fromMap({
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': DateTime.now().toIso8601String(),
    'scopes': ['a'],
    'userProfile': {'sub': '123', 'name': 'John Doe'},
    'type': 'Bearer'
  });
}

@GenerateMocks([TestPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockedPlatform = MockTestPlatform();

  setUp(() {
    CredentialsManagerPlatform.instance = mockedPlatform;
    reset(mockedPlatform);
  });

  group('getCredentials', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.getCredentials(any))
          .thenAnswer((final _) async => TestPlatform.credentials);

      await Auth0('test-domain', 'test-clientId')
          .credentialsManager()
          .getCredentials(
              minTtl: 30, scopes: {'a', 'b'}, parameters: {'a': 'b'});

      final verificationResult =
          verify(mockedPlatform.getCredentials(captureAny)).captured.single
              as CredentialsManagerRequest<GetCredentialsOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options?.minTtl, 30);
      expect(verificationResult.options?.scopes, {'a', 'b'});
      expect(verificationResult.options?.parameters, {'a': 'b'});
    });

    test('set minTtl, scope and parameters to default value when omitted', () async {
      when(mockedPlatform.getCredentials(any))
          .thenAnswer((final _) async => TestPlatform.credentials);

      await Auth0('test-domain', 'test-clientId')
          .credentialsManager()
          .getCredentials();

      final verificationResult =
          verify(mockedPlatform.getCredentials(captureAny)).captured.single
              as CredentialsManagerRequest<GetCredentialsOptions>;
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options?.minTtl, null);
      expect(verificationResult.options?.scopes, []);
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options?.parameters, null);
    });
  });

  group('saveCredentials', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.saveCredentials(any))
          .thenAnswer((final _) async => {});

      await Auth0('test-domain', 'test-clientId')
          .credentialsManager()
          .saveCredentials(TestPlatform.credentials);

      final verificationResult =
          verify(mockedPlatform.saveCredentials(captureAny)).captured.single
              as CredentialsManagerRequest<SaveCredentialsOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options?.credentials.accessToken,
          TestPlatform.credentials.accessToken);
      expect(verificationResult.options?.credentials.idToken,
          TestPlatform.credentials.idToken);
      expect(verificationResult.options?.credentials.refreshToken,
          TestPlatform.credentials.refreshToken);
      expect(verificationResult.options?.credentials.expiresAt,
          TestPlatform.credentials.expiresAt);
      expect(verificationResult.options?.credentials.scopes,
          TestPlatform.credentials.scopes);
      expect(verificationResult.options?.credentials.type,
          TestPlatform.credentials.type);
    });
  });

  group('hasValidCredentials', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.hasValidCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId')
          .credentialsManager()
          .hasValidCredentials(minTtl: 30);

      final verificationResult =
          verify(mockedPlatform.hasValidCredentials(captureAny)).captured.single
              as CredentialsManagerRequest<HasValidCredentialsOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options?.minTtl, 30);
    });

    test('does not use a default value for minTtl when omitted', () async {
      when(mockedPlatform.hasValidCredentials(any))
          .thenAnswer((final _) async => true);

      await Auth0('test-domain', 'test-clientId')
          .credentialsManager()
          .hasValidCredentials();

      final verificationResult =
          verify(mockedPlatform.hasValidCredentials(captureAny)).captured.single
              as CredentialsManagerRequest<HasValidCredentialsOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options?.minTtl, null);
    });

    test('returns the value from the platform when true', () async {
      when(mockedPlatform.hasValidCredentials(any))
          .thenAnswer((final _) async => true);

      final result = await Auth0('test-domain', 'test-clientId')
          .credentialsManager()
          .hasValidCredentials();

      expect(result, true);
    });

    test('returns the value from the platform when false', () async {
      when(mockedPlatform.hasValidCredentials(any))
          .thenAnswer((final _) async => false);

      final result = await Auth0('test-domain', 'test-clientId')
          .credentialsManager()
          .hasValidCredentials();

      expect(result, false);
    });
  });

  group('clearCredentials', () {
    test('calls the platform', () async {
      when(mockedPlatform.clearCredentials(any))
          .thenAnswer((final _) async => {});

      await Auth0('test-domain', 'test-clientId')
          .credentialsManager()
          .clearCredentials();

      final verificationResult =
          verify(mockedPlatform.clearCredentials(captureAny)).captured.single
              as CredentialsManagerRequest;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
    });
  });
}
