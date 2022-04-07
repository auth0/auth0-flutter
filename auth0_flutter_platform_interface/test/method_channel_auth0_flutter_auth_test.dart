import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'method_channel_auth0_flutter_auth_test.mocks.dart';

class MethodCallHandler {
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

  test('signUp - calls the correct MethodChannel method', () async {
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

    expect(verify(mocked.methodCallHandler(captureAny)).captured.single.method,
        'auth#signUp');
  });

  test('signUp - correctly maps all properties', () async {
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

  test('signUp - correctly returns the response from the Method Channel',
      () async {
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

  test('signUp - correctly returns emailVerified when true', () async {
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

  test('signUp - correctly returns emailVerified when false', () async {
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
}
