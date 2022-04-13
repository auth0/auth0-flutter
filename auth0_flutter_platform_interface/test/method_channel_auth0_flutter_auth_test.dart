import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'method_channel_auth0_flutter_auth_test.mocks.dart';

class MethodCallHandler {
  static const Map<dynamic, dynamic> loginResult = {
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': '2022-01-01',
    'scopes': ['a'],
    'userProfile': {'name': 'John Doe'}
  };

  static const Map<dynamic, dynamic> renewAccessTokenResult = {
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': '2022-01-01',
    'scopes': ['a'],
    'userProfile': {'name': 'John Doe'}
  };

  Future<dynamic>? methodCallHandler(final MethodCall? methodCall) async {}
}

@GenerateMocks([MethodCallHandler])
void main() {
  const MethodChannel channel = MethodChannel('auth0.com/auth0_flutter/auth');

  TestWidgetsFlutterBinding.ensureInitialized();

  final mocked = MockMethodCallHandler();

  setUp(() {
    channel.setMockMethodCallHandler(mocked.methodCallHandler);
    reset(mocked);
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('signup', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => {
            'email': 'test-email',
            'emailVerified': true,
            'username': 'test-user'
          });

      await MethodChannelAuth0FlutterAuth().signup(AuthSignupOptions(
          account: const Account('test-domain', 'test-clientId'),
          email: 'test-email',
          password: 'test-pass',
          connection: 'test-connection',
          username: 'test-user'));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#signUp');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => {
            'email': 'test-email',
            'emailVerified': true,
            'username': 'test-user'
          });

      await MethodChannelAuth0FlutterAuth().signup(AuthSignupOptions(
          account: const Account('test-domain', 'test-clientId'),
          email: 'test-email',
          password: 'test-pass',
          connection: 'test-connection',
          username: 'test-user'));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['domain'], 'test-domain');
      expect(verificationResult.arguments['clientId'], 'test-clientId');
      expect(verificationResult.arguments['email'], 'test-email');
      expect(verificationResult.arguments['username'], 'test-user');
      expect(verificationResult.arguments['password'], 'test-pass');
      expect(verificationResult.arguments['connection'], 'test-connection');
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => {
            'email': 'test-email',
            'emailVerified': true,
            'username': 'test-user'
          });

      final result = await MethodChannelAuth0FlutterAuth().signup(
          AuthSignupOptions(
              account: const Account('test-domain', 'test-clientId'),
              email: 'test-email',
              password: 'test-pass',
              connection: 'test-connection',
              username: 'test-user'));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.email, 'test-email');
      expect(result.emailVerified, true);
      expect(result.username, 'test-user');
    });

    test('correctly returns emailVerified when true', () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => {'email': 'test-email', 'emailVerified': true});

      final result = await MethodChannelAuth0FlutterAuth().signup(
          AuthSignupOptions(
              account: const Account('', ''),
              email: '',
              password: '',
              connection: ''));

      verify(mocked.methodCallHandler(captureAny));
      expect(result.emailVerified, true);
    });

    test('correctly returns emailVerified when false', () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => {'email': 'test-email', 'emailVerified': false});

      final result = await MethodChannelAuth0FlutterAuth().signup(
          AuthSignupOptions(
              account: const Account('', ''),
              email: '',
              password: '',
              connection: ''));

      verify(mocked.methodCallHandler(captureAny));
      expect(result.emailVerified, false);
    });

    test('throws an ApiException when method channel returns null', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<DatabaseUser> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().signup(
            AuthSignupOptions(
                account: const Account('', ''),
                email: '',
                password: '',
                connection: ''));

        return result;
      }

      expectLater(
          actual,
          throwsA(predicate((e) =>
              e is ApiException && e.message == 'Channel returned null.')));
    });

    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<DatabaseUser> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().signup(
            AuthSignupOptions(
                account: const Account('', ''),
                email: '',
                password: '',
                connection: ''));

        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
  });

  group('login', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      await MethodChannelAuth0FlutterAuth().login(AuthLoginOptions(
          account: const Account('', ''),
          usernameOrEmail: '',
          password: '',
          connectionOrRealm: ''));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#login');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      await MethodChannelAuth0FlutterAuth().login(AuthLoginOptions(
          account: const Account('test-domain', 'test-clientId'),
          usernameOrEmail: 'test-email',
          password: 'test-pass',
          connectionOrRealm: 'test-connection',
          scopes: {'a', 'b'},
          parameters: {'test': 'test-123'}));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['domain'], 'test-domain');
      expect(verificationResult.arguments['clientId'], 'test-clientId');
      expect(verificationResult.arguments['usernameOrEmail'], 'test-email');
      expect(verificationResult.arguments['password'], 'test-pass');
      expect(
          verificationResult.arguments['connectionOrRealm'], 'test-connection');
      expect(verificationResult.arguments['scopes'], ['a', 'b']);
      expect(verificationResult.arguments['parameters']['test'], 'test-123');
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any))
          .thenAnswer((final _) async => MethodCallHandler.loginResult);

      final result = await MethodChannelAuth0FlutterAuth().login(
          AuthLoginOptions(
              account: const Account('test-domain', 'test-clientId'),
              usernameOrEmail: 'test-email',
              password: 'test-pass',
              connectionOrRealm: 'test-connection'));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.accessToken, MethodCallHandler.loginResult['accessToken']);
      expect(result.idToken, MethodCallHandler.loginResult['idToken']);
      expect(result.expiresAt,
          DateTime.parse(MethodCallHandler.loginResult['expiresAt'] as String));
      expect(result.scopes, MethodCallHandler.loginResult['scopes']);
      expect(
          result.refreshToken, MethodCallHandler.loginResult['refreshToken']);
      expect(result.userProfile['name'],
          MethodCallHandler.loginResult['userProfile']['name']);
    });

    test('throws an ApiException when method channel returns null', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<Credentials> actual() async {
        final Credentials result = await MethodChannelAuth0FlutterAuth().login(
            AuthLoginOptions(
                account: const Account('test-domain', 'test-clientId'),
                usernameOrEmail: 'test-email',
                password: 'test-pass',
                connectionOrRealm: 'test-connection'));

        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });

    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<Credentials> actual() async {
        final Credentials result = await MethodChannelAuth0FlutterAuth().login(
            AuthLoginOptions(
                account: const Account('test-domain', 'test-clientId'),
                usernameOrEmail: 'test-email',
                password: 'test-pass',
                connectionOrRealm: 'test-connection'));

        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
  });

  group('resetPassword', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      await MethodChannelAuth0FlutterAuth().resetPassword(
          AuthResetPasswordOptions(
              account: const Account('test-domain', 'test-clientId'),
              email: 'test-email',
              connection: 'test-connection'));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#resetPassword');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      await MethodChannelAuth0FlutterAuth().resetPassword(
          AuthResetPasswordOptions(
              account: const Account('test-domain', 'test-clientId'),
              email: 'test-email',
              connection: 'test-connection',
              parameters: {'test': 'test-123'}));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['domain'], 'test-domain');
      expect(verificationResult.arguments['clientId'], 'test-clientId');
      expect(verificationResult.arguments['email'], 'test-email');
      expect(verificationResult.arguments['connection'], 'test-connection');
      expect(verificationResult.arguments['parameters']['test'], 'test-123');
    });

    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<void> actual() async {
        await MethodChannelAuth0FlutterAuth().resetPassword(
            AuthResetPasswordOptions(
                account: const Account('test-domain', 'test-clientId'),
                email: 'test-email',
                connection: 'test-connection',
                parameters: {'test': 'test-123'}));
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
  });

  group('renewAccessToken', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => MethodCallHandler.renewAccessTokenResult);

      await MethodChannelAuth0FlutterAuth().renewAccessToken(
          AuthRenewAccessTokenOptions(
              account: const Account('test-domain', 'test-clientId'),
              refreshToken: 'test-refresh-token'));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#renewAccessToken');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => MethodCallHandler.renewAccessTokenResult);

      await MethodChannelAuth0FlutterAuth().renewAccessToken(
          AuthRenewAccessTokenOptions(
              refreshToken: 'test-refresh-token',
              account: const Account('test-domain', 'test-clientId')));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['domain'], 'test-domain');
      expect(verificationResult.arguments['clientId'], 'test-clientId');
      expect(
          verificationResult.arguments['refreshToken'], 'test-refresh-token');
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => MethodCallHandler.renewAccessTokenResult);

      final result = await MethodChannelAuth0FlutterAuth().renewAccessToken(
          AuthRenewAccessTokenOptions(
              refreshToken: 'test-refresh-token',
              account: const Account('test-domain', 'test-clientId')));

      expect(result.accessToken,
          MethodCallHandler.renewAccessTokenResult['accessToken']);
      expect(result.idToken,
          MethodCallHandler.renewAccessTokenResult['idToken']);
      expect(result.refreshToken,
          MethodCallHandler.renewAccessTokenResult['refreshToken']);
      expect(result.scopes,
          MethodCallHandler.renewAccessTokenResult['scopes']);
      expect(result.expiresAt,
          DateTime.parse(MethodCallHandler.renewAccessTokenResult['expiresAt'] as String));
      expect(result.userProfile['name'],
          MethodCallHandler.renewAccessTokenResult['userProfile']['name']);
    });

    test('throws an ApiException when method channel returns null', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

      Future<Credentials> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().renewAccessToken(
          AuthRenewAccessTokenOptions(
              refreshToken: 'test-refresh-token',
              account: const Account('test-domain', 'test-clientId')));

        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });

    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<Credentials> actual() async {
        final result = await MethodChannelAuth0FlutterAuth().renewAccessToken(
          AuthRenewAccessTokenOptions(
              refreshToken: 'test-refresh-token',
              account: const Account('test-domain', 'test-clientId')));


        return result;
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
  });
}
