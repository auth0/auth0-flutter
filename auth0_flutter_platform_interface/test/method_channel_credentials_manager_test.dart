// ignore_for_file: lines_longer_than_80_chars

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'method_channel_credentials_manager_test.mocks.dart';

class MethodCallHandler {
  static const Map<dynamic, dynamic> credentials = {
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'expiresAt': '2023-11-01T22:16:35.760Z',
    'scopes': ['a', 'b'],
    'userProfile': {'sub': '123', 'name': 'John Doe'},
    'tokenType': 'Bearer'
  };

  Future<dynamic>? methodCallHandler(final MethodCall? methodCall) async {}
}

@GenerateMocks([MethodCallHandler])
void main() {
  const MethodChannel channel =
      MethodChannel('auth0.com/auth0_flutter/credentials_manager');

  TestWidgetsFlutterBinding.ensureInitialized();

  final mocked = MockMethodCallHandler();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, mocked.methodCallHandler);
    reset(mocked);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('getCredentials', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.credentials);

      await MethodChannelCredentialsManager().getCredentials(
          CredentialsManagerRequest<GetCredentialsOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: GetCredentialsOptions()));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'credentialsManager#getCredentials');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.credentials);

      await MethodChannelCredentialsManager()
          .getCredentials(CredentialsManagerRequest<GetCredentialsOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: GetCredentialsOptions(
                minTtl: 30,
                scopes: {'test-scope1', 'test-scope2'},
                parameters: {'test': 'test-123'},
              )));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['minTtl'], 30);
      expect(verificationResult.arguments['scopes'],
          ['test-scope1', 'test-scope2']);
      expect(verificationResult.arguments['parameters']['test'], 'test-123');
    });

    test(
        'correctly assigns default values to all non-required properties when missing',
        () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.credentials);

      await MethodChannelCredentialsManager().getCredentials(
          CredentialsManagerRequest<GetCredentialsOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: '', version: ''),
              options: GetCredentialsOptions()));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['minTtl'], 0);
      expect(verificationResult.arguments['scopes'], isEmpty);
      expect(verificationResult.arguments['parameters'], isEmpty);
    });

    test('correctly includes the local authentication settings', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.credentials);

      await MethodChannelCredentialsManager().getCredentials(
          CredentialsManagerRequest<GetCredentialsOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: '', version: ''),
              options: GetCredentialsOptions(),
              localAuthentication: const LocalAuthentication(
                  title: 'test-title',
                  description: 'test-description',
                  cancelTitle: 'test-cancel-title',
                  fallbackTitle: 'test-fallback-title')));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['localAuthentication']['title'],
          'test-title');
      expect(verificationResult.arguments['localAuthentication']['description'],
          'test-description');
      expect(verificationResult.arguments['localAuthentication']['cancelTitle'],
          'test-cancel-title');
      expect(
          verificationResult.arguments['localAuthentication']['fallbackTitle'],
          'test-fallback-title');
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.credentials);

      final result = await MethodChannelCredentialsManager()
          .getCredentials(CredentialsManagerRequest<GetCredentialsOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: GetCredentialsOptions(
                minTtl: 30,
                scopes: {'test-scope1', 'test-scope2'},
                parameters: {'test': 'test-123'},
              )));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.accessToken, MethodCallHandler.credentials['accessToken']);
      expect(result.idToken, MethodCallHandler.credentials['idToken']);
      expect(
          result.refreshToken, MethodCallHandler.credentials['refreshToken']);
      expect(result.scopes, MethodCallHandler.credentials['scopes']);
      expect(result.expiresAt,
          DateTime.parse(MethodCallHandler.credentials['expiresAt'] as String));
      expect(result.tokenType, MethodCallHandler.credentials['tokenType']);
    });

    test(
        'throws a CredentialsManagerException when method channel returns null',
        () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<Credentials> actual() async {
        final result = await MethodChannelCredentialsManager().getCredentials(
            CredentialsManagerRequest<GetCredentialsOptions>(
                account: const Account('', ''),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: GetCredentialsOptions()));

        return result;
      }

      expectLater(
          actual,
          throwsA(predicate((final e) =>
              e is CredentialsManagerException &&
              e.message == 'Channel returned null.')));
    });

    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<Credentials> actual() async {
        final result = await MethodChannelCredentialsManager().getCredentials(
            CredentialsManagerRequest<GetCredentialsOptions>(
                account: const Account('', ''),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: GetCredentialsOptions()));

        return result;
      }

      await expectLater(actual, throwsA(isA<CredentialsManagerException>()));
    });
  });

  group('saveCredentials', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => true);

      final credentials = Credentials.fromMap({
        'accessToken': 'accessToken',
        'idToken': 'idToken',
        'refreshToken': 'refreshToken',
        'expiresAt': DateTime.now().toIso8601String(),
        'scopes': ['a'],
        'userProfile': {'sub': '123', 'name': 'John Doe'},
        'tokenType': 'Bearer',
      });

      await MethodChannelCredentialsManager().saveCredentials(
          CredentialsManagerRequest<SaveCredentialsOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: SaveCredentialsOptions(credentials: credentials)));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'credentialsManager#saveCredentials');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => true);

      final credentials = Credentials.fromMap({
        'accessToken': 'accessToken',
        'idToken': 'idToken',
        'refreshToken': 'refreshToken',
        'expiresAt': DateTime.now().toIso8601String(),
        'scopes': ['a'],
        'userProfile': {'sub': '123', 'name': 'John Doe'},
        'tokenType': 'Bearer',
      });

      await MethodChannelCredentialsManager().saveCredentials(
          CredentialsManagerRequest<SaveCredentialsOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: SaveCredentialsOptions(credentials: credentials)));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['credentials'], isNotNull);
      expect(verificationResult.arguments['credentials']['accessToken'],
          credentials.accessToken);
      expect(verificationResult.arguments['credentials']['idToken'],
          credentials.idToken);
      expect(verificationResult.arguments['credentials']['refreshToken'],
          credentials.refreshToken);
      expect(verificationResult.arguments['credentials']['expiresAt'],
          credentials.expiresAt.toIso8601String());
      expect(verificationResult.arguments['credentials']['scopes'], ['a']);
      expect(
          verificationResult.arguments['credentials']['tokenType'], 'Bearer');
      expect(
        verificationResult.arguments['credentials']['userProfile'],
        isNotNull,
      );
    });

    test(
        'throws a CredentialsManagerException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      final credentials = Credentials.fromMap({
        'accessToken': 'accessToken',
        'idToken': 'idToken',
        'refreshToken': 'refreshToken',
        'expiresAt': DateTime.now().toIso8601String(),
        'scopes': ['a'],
        'userProfile': {'sub': '123', 'name': 'John Doe'},
        'tokenType': 'Bearer',
      });

      Future<bool> actual() async {
        final result = await MethodChannelCredentialsManager().saveCredentials(
            CredentialsManagerRequest<SaveCredentialsOptions>(
                account: const Account('', ''),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: SaveCredentialsOptions(credentials: credentials)));

        return result;
      }

      await expectLater(actual, throwsA(isA<CredentialsManagerException>()));
    });

    test(
        'throws a CredentialsManagerException when method channel returns null',
        () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      final credentials = Credentials.fromMap({
        'accessToken': 'accessToken',
        'idToken': 'idToken',
        'refreshToken': 'refreshToken',
        'expiresAt': DateTime.now().toIso8601String(),
        'scopes': ['a'],
        'userProfile': {'sub': '123', 'name': 'John Doe'},
        'tokenType': 'Bearer',
      });

      Future<bool> actual() async {
        final result = await MethodChannelCredentialsManager().saveCredentials(
            CredentialsManagerRequest<SaveCredentialsOptions>(
                account: const Account('', ''),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: SaveCredentialsOptions(credentials: credentials)));

        return result;
      }

      expectLater(
          actual,
          throwsA(predicate((final e) =>
              e is CredentialsManagerException &&
              e.message == 'Channel returned null.')));
    });
  });

  group('hasValidCredentials', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => true);

      await MethodChannelCredentialsManager().hasValidCredentials(
          CredentialsManagerRequest<HasValidCredentialsOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: HasValidCredentialsOptions()));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'credentialsManager#hasValidCredentials');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => true);

      await MethodChannelCredentialsManager().hasValidCredentials(
          CredentialsManagerRequest<HasValidCredentialsOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: HasValidCredentialsOptions(minTtl: 30)));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;

      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['minTtl'], 30);
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => false);

      final result = await MethodChannelCredentialsManager()
          .hasValidCredentials(
              CredentialsManagerRequest<HasValidCredentialsOptions>(
                  account: const Account('test-domain', 'test-clientId'),
                  userAgent:
                      UserAgent(name: 'test-name', version: 'test-version'),
                  options: HasValidCredentialsOptions()));

      verify(mocked.methodCallHandler(captureAny));

      expect(result, false);
    });

    test(
        'throws a CredentialsManagerException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<bool> actual() async {
        final result = await MethodChannelCredentialsManager()
            .hasValidCredentials(
                CredentialsManagerRequest<HasValidCredentialsOptions>(
                    account: const Account('', ''),
                    userAgent:
                        UserAgent(name: 'test-name', version: 'test-version'),
                    options: HasValidCredentialsOptions()));

        return result;
      }

      await expectLater(actual, throwsA(isA<CredentialsManagerException>()));
    });

    test(
        'throws a CredentialsManagerException when method channel returns null',
        () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<bool> actual() async {
        final result = await MethodChannelCredentialsManager()
            .hasValidCredentials(
                CredentialsManagerRequest<HasValidCredentialsOptions>(
                    account: const Account('', ''),
                    userAgent:
                        UserAgent(name: 'test-name', version: 'test-version'),
                    options: HasValidCredentialsOptions()));

        return result;
      }

      expectLater(
          actual,
          throwsA(predicate((final e) =>
              e is CredentialsManagerException &&
              e.message == 'Channel returned null.')));
    });
  });

  group('clearCredentials', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => true);

      await MethodChannelCredentialsManager().clearCredentials(
          CredentialsManagerRequest(
              account: const Account('test-domain', 'test-clientId'),
              userAgent:
                  UserAgent(name: 'test-name', version: 'test-version')));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'credentialsManager#clearCredentials');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => true);

      await MethodChannelCredentialsManager().clearCredentials(
          CredentialsManagerRequest(
              account: const Account('test-domain', 'test-clientId'),
              userAgent:
                  UserAgent(name: 'test-name', version: 'test-version')));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(verificationResult.arguments['_userAgent']['version'],
          'test-version');
    });

    test(
        'throws a CredentialsManagerException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<bool> actual() async {
        final result = await MethodChannelCredentialsManager().clearCredentials(
            CredentialsManagerRequest(
                account: const Account('', ''),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version')));

        return result;
      }

      await expectLater(actual, throwsA(isA<CredentialsManagerException>()));
    });

    test(
        'throws a CredentialsManagerException when method channel returns null',
        () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<bool> actual() async {
        final result = await MethodChannelCredentialsManager().clearCredentials(
            CredentialsManagerRequest(
                account: const Account('', ''),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version')));

        return result;
      }

      expectLater(
          actual,
          throwsA(predicate((final e) =>
              e is CredentialsManagerException &&
              e.message == 'Channel returned null.')));
    });
  });
}
