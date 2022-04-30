import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'method_channel_auth0_flutter_web_auth_test.mocks.dart';

class MethodCallHandler {
  static const Map<dynamic, dynamic> loginResultRequired = {
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'expiresAt': '2022-01-01',
    'scopes': ['a', 'b'],
    'userProfile': {'sub': '123', 'name': 'John Doe'}
  };

  static const Map<dynamic, dynamic> loginResult = {
    ...loginResultRequired,
    'refreshToken': 'refreshToken'
  };

  Future<dynamic>? methodCallHandler(final MethodCall? methodCall) async {
    if (methodCall?.method == 'webAuth#login') {
      return loginResult;
    }
  }
}

@GenerateMocks([MethodCallHandler])
void main() {
  const MethodChannel channel =
      MethodChannel('auth0.com/auth0_flutter/web_auth');

  TestWidgetsFlutterBinding.ensureInitialized();

  final mocked = MockMethodCallHandler();

  setUp(() {
    channel.setMockMethodCallHandler(mocked.methodCallHandler);
    reset(mocked);
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('login', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      await MethodChannelAuth0FlutterWebAuth().login(
          WebAuthRequest<WebAuthLoginOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: WebAuthLoginOptions()));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'webAuth#login');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      await MethodChannelAuth0FlutterWebAuth().login(
          WebAuthRequest<WebAuthLoginOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: WebAuthLoginOptions(
                  scopes: {'a', 'b'},
                  audience: 'test-audience',
                  redirectUrl: 'http://google.com',
                  organizationId: 'test-org',
                  invitationUrl: 'http://invite.com',
                  parameters: {'test': 'test-123'},
                  scheme: 'test-scheme',
                  useEphemeralSession: true,
                  idTokenValidationConfig: const IdTokenValidationConfig(
                      leeway: 10, issuer: 'test-issuer', maxAge: 20))));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(
          verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['scopes'], ['a', 'b']);
      expect(verificationResult.arguments['audience'], 'test-audience');
      expect(verificationResult.arguments['redirectUrl'], 'http://google.com');
      expect(verificationResult.arguments['organizationId'], 'test-org');
      expect(
          verificationResult.arguments['invitationUrl'], 'http://invite.com');
      expect(verificationResult.arguments['parameters']['test'], 'test-123');
      expect(verificationResult.arguments['scheme'], 'test-scheme');
      expect(verificationResult.arguments['useEphemeralSession'], true);
      expect(verificationResult.arguments['leeway'], 10);
      expect(verificationResult.arguments['issuer'], 'test-issuer');
      expect(verificationResult.arguments['maxAge'], 20);
    });

    test(
        'correctly assigns default values to all non-required properties when missing',
        () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      await MethodChannelAuth0FlutterWebAuth().login(
          WebAuthRequest<WebAuthLoginOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: '', version: ''),
              options: WebAuthLoginOptions()));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['scopes'], isEmpty);
      expect(verificationResult.arguments['audience'], isNull);
      expect(verificationResult.arguments['redirectUrl'], isNull);
      expect(verificationResult.arguments['organizationId'], isNull);
      expect(verificationResult.arguments['invitationUrl'], isNull);
      expect(verificationResult.arguments['parameters'], isEmpty);
      expect(verificationResult.arguments['scheme'], isNull);
      expect(verificationResult.arguments['useEphemeralSession'], false);
      expect(verificationResult.arguments['idTokenValidationConfig'], isNull);
    });
   
    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      final result = await MethodChannelAuth0FlutterWebAuth().login(
          WebAuthRequest(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: WebAuthLoginOptions()));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.accessToken, MethodCallHandler.loginResult['accessToken']);
      expect(result.idToken, MethodCallHandler.loginResult['idToken']);
      expect(result.expiresAt,
          DateTime.parse(MethodCallHandler.loginResult['expiresAt'] as String));
      expect(result.scopes, MethodCallHandler.loginResult['scopes']);
      expect(
          result.refreshToken, MethodCallHandler.loginResult['refreshToken']);
      expect(result.userProfile.name,
          MethodCallHandler.loginResult['userProfile']['name']);
    });
  
    test(
        'correctly returns the response from the Method Channel when properties missing',
        () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResultRequired);

      final result = await MethodChannelAuth0FlutterWebAuth().login(
          WebAuthRequest(
              account: const Account('', ''),
              userAgent: UserAgent(name: '', version: ''),
              options: WebAuthLoginOptions()));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.refreshToken, isNull);
    });

    test('throws an WebAuthException when method channel returns null',
        () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<Credentials> actual() async {
        final result = await MethodChannelAuth0FlutterWebAuth().login(
            WebAuthRequest(
                account: const Account('test-domain', 'test-clientId'),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: WebAuthLoginOptions()));
        return result;
      }

      await expectLater(actual, throwsA(isA<WebAuthException>()));
    });

    test(
        'throws an WebAuthException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<Credentials> actual() async {
        final result = await MethodChannelAuth0FlutterWebAuth().login(
            WebAuthRequest(
                account: const Account('test-domain', 'test-clientId'),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: WebAuthLoginOptions()));

        return result;
      }

      await expectLater(actual, throwsA(isA<WebAuthException>()));
    });
  });

  group('logout', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      await MethodChannelAuth0FlutterWebAuth().logout(
          WebAuthRequest<WebAuthLogoutOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: WebAuthLogoutOptions()));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'webAuth#logout');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      await MethodChannelAuth0FlutterWebAuth().logout(
          WebAuthRequest<WebAuthLogoutOptions>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: WebAuthLogoutOptions(
                  returnTo: 'http://localhost:1234', scheme: 'test-scheme')));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['_account']['domain'], 'test-domain');
      expect(verificationResult.arguments['_account']['clientId'],
          'test-clientId');
      expect(verificationResult.arguments['_userAgent']['name'], 'test-name');
      expect(
          verificationResult.arguments['_userAgent']['version'],
          'test-version');
      expect(verificationResult.arguments['returnTo'], 'http://localhost:1234');
      expect(verificationResult.arguments['scheme'], 'test-scheme');
    });

    test(
        'correctly assigns default values to all non-required properties when missing',
        () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      await MethodChannelAuth0FlutterWebAuth().logout(
          WebAuthRequest<WebAuthLogoutOptions>(
              account: const Account('', ''),
              userAgent: UserAgent(name: '', version: ''),
              options: WebAuthLogoutOptions()));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['returnTo'], isNull);
      expect(verificationResult.arguments['scheme'], isNull);
    });
  
    test(
        'throws an WebAuthException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<void> actual() async {
        await MethodChannelAuth0FlutterWebAuth().logout(
            WebAuthRequest<WebAuthLogoutOptions>(
                account: const Account('test-domain', 'test-clientId'),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: WebAuthLogoutOptions()));
      }

      await expectLater(actual, throwsA(isA<WebAuthException>()));
    });
  });
}
