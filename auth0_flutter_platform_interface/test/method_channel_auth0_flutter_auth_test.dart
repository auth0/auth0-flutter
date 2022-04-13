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
  });

  test('login', () async {
    when(mocked.methodCallHandler(any))
        .thenAnswer((final _) async => MethodCallHandler.loginResult);

    final result = await MethodChannelAuth0FlutterAuth().login(AuthLoginOptions(
        account: const Account('', ''),
        usernameOrEmail: '',
        password: '',
        connectionOrRealm: ''));

    expect(verify(mocked.methodCallHandler(captureAny)).captured.single.method,
        'auth#login');
    expect(result.accessToken, MethodCallHandler.loginResult['accessToken']);
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
}
