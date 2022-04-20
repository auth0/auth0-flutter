import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'method_channel_auth0_flutter_web_auth_test.mocks.dart';

class MethodCallHandler {
  static const Map<dynamic, dynamic> loginResult = {
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': '2022-01-01',
    'scopes': ['a'],
    'userProfile': {'sub': '123', 'name': 'John Doe'}
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
          WebAuthRequest<WebAuthLoginInput>(
              account: const Account('', ''),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: WebAuthLoginInput(scopes: {})));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'webAuth#login');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      await MethodChannelAuth0FlutterWebAuth().login(
          WebAuthRequest<WebAuthLoginInput>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: WebAuthLoginInput(
                  scopes: {'a', 'b'},
                  audience: 'test-audience',
                  redirectUri: 'http://google.com',
                  organizationId: 'test-org',
                  invitationUrl: 'http://invite.com',
                  parameters: {'test': 'test-123'},
                  scheme: 'test-scheme',
                  useEphemeralSession: true,
                  idTokenValidationConfig: const IdTokenValidationConfig(
                      leeway: 10, issuer: 'test-issuer', maxAge: 20))));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['domain'], 'test-domain');
      expect(verificationResult.arguments['clientId'], 'test-clientId');
      expect(verificationResult.arguments['userAgent']['name'], 'test-name');
      expect(
          verificationResult.arguments['userAgent']['version'], 'test-version');
      expect(verificationResult.arguments['scopes'], ['a', 'b']);
      expect(verificationResult.arguments['audience'], 'test-audience');
      expect(verificationResult.arguments['redirectUri'], 'http://google.com');
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

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      final result = await MethodChannelAuth0FlutterWebAuth().login(
          WebAuthRequest(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: WebAuthLoginInput(scopes: {'a', 'b'})));

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

    test('throws an WebAuthException when method channel returns null',
        () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<Credentials> actual() async {
        final result = await MethodChannelAuth0FlutterWebAuth().login(
            WebAuthRequest(
                account: const Account('test-domain', 'test-clientId'),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: WebAuthLoginInput(scopes: {'a', 'b'})));
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
                options: WebAuthLoginInput(scopes: {'a', 'b'})));

        return result;
      }

      await expectLater(actual, throwsA(isA<WebAuthException>()));
    });
  });

  group('logout', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      await MethodChannelAuth0FlutterWebAuth().logout(
          WebAuthRequest<WebAuthLogoutInput>(
              account: const Account('', ''),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: WebAuthLogoutInput()));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'webAuth#logout');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      await MethodChannelAuth0FlutterWebAuth().logout(
          WebAuthRequest<WebAuthLogoutInput>(
              account: const Account('test-domain', 'test-clientId'),
              userAgent: UserAgent(name: 'test-name', version: 'test-version'),
              options: WebAuthLogoutInput(
                  returnTo: 'http://localhost:1234', scheme: 'test-scheme')));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['domain'], 'test-domain');
      expect(verificationResult.arguments['clientId'], 'test-clientId');
      expect(verificationResult.arguments['userAgent']['name'], 'test-name');
      expect(
          verificationResult.arguments['userAgent']['version'], 'test-version');
      expect(verificationResult.arguments['returnTo'], 'http://localhost:1234');
      expect(verificationResult.arguments['scheme'], 'test-scheme');
    });

    test(
        'throws an WebAuthException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<void> actual() async {
        await MethodChannelAuth0FlutterWebAuth().logout(
            WebAuthRequest<WebAuthLogoutInput>(
                account: const Account('test-domain', 'test-clientId'),
                userAgent:
                    UserAgent(name: 'test-name', version: 'test-version'),
                options: WebAuthLogoutInput()));
      }

      await expectLater(actual, throwsA(isA<WebAuthException>()));
    });
  });
}
