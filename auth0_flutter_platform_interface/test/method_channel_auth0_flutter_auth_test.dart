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

  group('renewAccessToken', () {
    test('returns the response', () async {
      when(mocked.methodCallHandler(any)).thenAnswer(
          (final _) async => MethodCallHandler.renewAccessTokenResult);

      final result = await MethodChannelAuth0FlutterAuth().renewAccessToken(
          AuthRenewAccessTokenOptions(
              refreshToken: 'test-refresh-token',
              account: const Account('test-domain', 'test-clientId')));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#renewAccessToken');
      expect(result.accessToken,
          MethodCallHandler.renewAccessTokenResult['accessToken']);
      expect(result.userProfile['name'],
          MethodCallHandler.renewAccessTokenResult['userProfile']['name']);
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
  });

  group('userInfo', () {
    test('calls the correct MethodChannel method', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => {});

      await MethodChannelAuth0FlutterAuth().userInfo(AuthUserInfoOptions(
          account: const Account('test-domain', 'test-clientId'),
          accessToken: 'test-token'));

      expect(
          verify(mocked.methodCallHandler(captureAny)).captured.single.method,
          'auth#userInfo');
    });

    test('correctly maps all properties', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => {
            'email': 'test-email',
            'nickname': 'test-nickname',
            'familyName': 'test-family-name'
          });

      await MethodChannelAuth0FlutterAuth().userInfo(AuthUserInfoOptions(
          account: const Account('test-domain', 'test-clientId'),
          accessToken: 'test-token'));

      final verificationResult =
          verify(mocked.methodCallHandler(captureAny)).captured.single;
      expect(verificationResult.arguments['domain'], 'test-domain');
      expect(verificationResult.arguments['clientId'], 'test-clientId');
      expect(verificationResult.arguments['accessToken'], 'test-token');
    });

    test('correctly returns the response from the Method Channel', () async {
      when(mocked.methodCallHandler(any)).thenAnswer((final _) async => {
            'email': 'test-email',
            'nickname': 'test-nickname',
            'familyName': 'test-family-name',
            'createdAt': '2022-04-01',
            'name': 'test-name',
            'givenName': 'test-given-name',
            'isEmailVerified': true,
            'userMetadata': {'test1': 'test1!'},
            'appMetadata': {'test2': 'test2!'},
            'extraInfo': {'test3': 'test3!'}
          });

      final result = await MethodChannelAuth0FlutterAuth().userInfo(
          AuthUserInfoOptions(
              account: const Account('test-domain', 'test-clientId'),
              accessToken: 'test-token'));

      verify(mocked.methodCallHandler(captureAny));

      expect(result.email, 'test-email');
      expect(result.nickname, 'test-nickname');
      expect(result.familyName, 'test-family-name');
      expect(result.createdAt, DateTime.parse('2022-04-01'));
      expect(result.name, 'test-name');
      expect(result.givenName, 'test-given-name');
      expect(result.isEmailVerified, true);
      expect(result.userMetadata?['test1'], 'test1!');
      expect(result.appMetadata?['test2'], 'test2!');
      expect(result.extraInfo?['test3'], 'test3!');
    });

    test(
        'throws an ApiException when method channel throws a PlatformException',
        () async {
      when(mocked.methodCallHandler(any))
          .thenThrow(PlatformException(code: '123'));

      Future<void> actual() async {
        await MethodChannelAuth0FlutterAuth().userInfo(AuthUserInfoOptions(
            account: const Account('test-domain', 'test-clientId'),
            accessToken: 'test-token'));
      }

      await expectLater(actual, throwsA(isA<ApiException>()));
    });
  });
}
