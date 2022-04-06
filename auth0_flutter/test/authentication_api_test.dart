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
  static LoginResult loginResult = LoginResult(
      accessToken: 'accessToken',
      idToken: 'idToken',
      refreshToken: 'refreshToken',
      expiresAt: DateTime.now(),
      scopes: {'a'},
      userProfile: {'name': 'John Doe'});
}

@GenerateMocks([TestPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockedPlatform = MockTestPlatform();

  setUp(() {
    Auth0FlutterAuthPlatform.instance = mockedPlatform;
    reset(mockedPlatform);
  });

  test('login - passes through properties to the platform', () async {
    when(mockedPlatform.login(any))
        .thenAnswer((final _) async => TestPlatform.loginResult);

    final result = await Auth0('test-domain', 'test-clientId')
        .api
        .login(
            usernameOrEmail: 'test-user',
            password: 'test-pass',
            connectionOrRealm: 'test-realm',
            scope: {'test-scope1', 'test-scope2'},
            parameters: {
              'test': 'test-parameter'
            });

    final verificationResult =
        verify(mockedPlatform.login(captureAny)).captured.single;
    expect(verificationResult.account.domain, 'test-domain');
    expect(verificationResult.account.clientId, 'test-clientId');
    expect(verificationResult.usernameOrEmail, 'test-user');
    expect(verificationResult.password, 'test-pass');
    expect(verificationResult.connectionOrRealm, 'test-realm');
    expect(verificationResult.scope, {'test-scope1', 'test-scope2'});
    expect(verificationResult.parameters['test'], 'test-parameter');
    expect(result, TestPlatform.loginResult);
  });

    test('login - set scope and parameters to default value when omitted', () async {
    when(mockedPlatform.login(any))
        .thenAnswer((final _) async => TestPlatform.loginResult);

    final result = await Auth0('test-domain', 'test-clientId')
        .api
        .login(
            usernameOrEmail: 'test-user',
            password: 'test-pass',
            connectionOrRealm: 'test-realm');

    final verificationResult =
        verify(mockedPlatform.login(captureAny)).captured.single;
    // ignore: inference_failure_on_collection_literal
    expect(verificationResult.scope, []);
    // ignore: inference_failure_on_collection_literal
    expect(verificationResult.parameters, {});
    expect(result, TestPlatform.loginResult);
  });
}
