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
  static final DateTime _testExpiresAtUtc = DateTime.utc(2023, 11, 1, 22, 16, 35, 760);
  static Credentials credentials = Credentials.fromMap({
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': _testExpiresAtUtc.toIso8601String(),
    'scopes': ['a'],
    'userProfile': {'sub': '123', 'name': 'John Doe'},
    'tokenType': 'Bearer'
  });
}

@GenerateMocks([TestPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockedPlatform = MockTestPlatform();
  const account = Account('test-domain', 'test-clientId');
  final userAgent = UserAgent(name: 'test', version: '0.0.1');

  setUp(() {
    CredentialsManagerPlatform.instance = mockedPlatform;
    reset(mockedPlatform);
  });

  group('credentials', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.getCredentials(any))
          .thenAnswer((final _) async => TestPlatform.credentials);

      await DefaultCredentialsManager(account, userAgent)
          .credentials(minTtl: 30, scopes: {'a', 'b'}, parameters: {'a': 'b'});

      final verificationResult =
          verify(mockedPlatform.getCredentials(captureAny)).captured.single
              as CredentialsManagerRequest<GetCredentialsOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options?.minTtl, 30);
      expect(verificationResult.options?.scopes, {'a', 'b'});
      expect(verificationResult.options?.parameters, {'a': 'b'});
    });

    test('passes forceRefresh: true to the platform', () async {
      when(mockedPlatform.getCredentials(any))
          .thenAnswer((final _) async => TestPlatform.credentials);

      await DefaultCredentialsManager(account, userAgent)
          .credentials(forceRefresh: true, scopes: {'openid', 'profile', 'offline_access'});

      final verificationResult =
      verify(mockedPlatform.getCredentials(captureAny)).captured.single
      as CredentialsManagerRequest<GetCredentialsOptions>;
      expect(verificationResult.options?.forceRefresh, true);
    });

    test('passes forceRefresh: false to the platform when explicitly set', () async {
      when(mockedPlatform.getCredentials(any))
          .thenAnswer((final _) async => TestPlatform.credentials);

      await DefaultCredentialsManager(account, userAgent)
          .credentials(forceRefresh: false);

      final verificationResult =
      verify(mockedPlatform.getCredentials(captureAny)).captured.single
      as CredentialsManagerRequest<GetCredentialsOptions>;
      expect(verificationResult.options?.forceRefresh, false);
    });

    test('set minTtl, scope and parameters to default value when omitted',
        () async {
      when(mockedPlatform.getCredentials(any))
          .thenAnswer((final _) async => TestPlatform.credentials);

      await DefaultCredentialsManager(account, userAgent).credentials();

      final verificationResult =
          verify(mockedPlatform.getCredentials(captureAny)).captured.single
              as CredentialsManagerRequest<GetCredentialsOptions>;
      expect(verificationResult.options?.minTtl, 0);
      // ignore: inference_failure_on_collection_literal
      expect(verificationResult.options?.scopes, isEmpty);
      expect(verificationResult.options?.parameters, isEmpty);
      expect(verificationResult.options?.forceRefresh, false);
    });
  });

  group('storeCredentials', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.saveCredentials(any))
          .thenAnswer((final _) async => true);

      await DefaultCredentialsManager(account, userAgent)
          .storeCredentials(TestPlatform.credentials);

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
      expect(verificationResult.options?.credentials.tokenType,
          TestPlatform.credentials.tokenType);
    });
  });

  group('hasValidCredentials', () {
    test('passes through properties to the platform', () async {
      when(mockedPlatform.hasValidCredentials(any))
          .thenAnswer((final _) async => true);

      await DefaultCredentialsManager(account, userAgent)
          .hasValidCredentials(minTtl: 30);

      final verificationResult =
          verify(mockedPlatform.hasValidCredentials(captureAny)).captured.single
              as CredentialsManagerRequest<HasValidCredentialsOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options?.minTtl, 30);
    });

    test('uses a default value for minTtl when omitted', () async {
      when(mockedPlatform.hasValidCredentials(any))
          .thenAnswer((final _) async => true);

      await DefaultCredentialsManager(account, userAgent).hasValidCredentials();

      final verificationResult =
          verify(mockedPlatform.hasValidCredentials(captureAny)).captured.single
              as CredentialsManagerRequest<HasValidCredentialsOptions>;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
      expect(verificationResult.options?.minTtl, 0);
    });

    test('returns the value from the platform when true', () async {
      when(mockedPlatform.hasValidCredentials(any))
          .thenAnswer((final _) async => true);

      final result = await DefaultCredentialsManager(account, userAgent)
          .hasValidCredentials();

      expect(result, true);
    });

    test('returns the value from the platform when false', () async {
      when(mockedPlatform.hasValidCredentials(any))
          .thenAnswer((final _) async => false);

      final result = await DefaultCredentialsManager(account, userAgent)
          .hasValidCredentials();

      expect(result, false);
    });
  });

  group('clearCredentials', () {
    test('calls the platform', () async {
      when(mockedPlatform.clearCredentials(any))
          .thenAnswer((final _) async => true);

      await DefaultCredentialsManager(account, userAgent).clearCredentials();

      final verificationResult =
          verify(mockedPlatform.clearCredentials(captureAny)).captured.single
              as CredentialsManagerRequest;
      expect(verificationResult.account.domain, 'test-domain');
      expect(verificationResult.account.clientId, 'test-clientId');
    });
  });
}
