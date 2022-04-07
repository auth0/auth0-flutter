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
  static DatabaseUser signupResult =
      DatabaseUser(email: 'email', emailVerified: true);
}

@GenerateMocks([TestPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockedPlatform = MockTestPlatform();

  setUp(() {
    Auth0FlutterAuthPlatform.instance = mockedPlatform;
    reset(mockedPlatform);
  });

  test('signUp - passes through properties to the platform', () async {
    when(mockedPlatform.signup(any))
        .thenAnswer((final _) async => TestPlatform.signupResult);

    final result = await Auth0('test-domain', 'test-clientId').api.signup(
      email: 'test-email',
      password: 'test-pass',
      connection: 'test-realm',
      userMetadata: {'test': 'test-123'},
    );

    final verificationResult =
        verify(mockedPlatform.signup(captureAny)).captured.single;
    expect(verificationResult.account.domain, 'test-domain');
    expect(verificationResult.account.clientId, 'test-clientId');
    expect(verificationResult.email, 'test-email');
    expect(verificationResult.password, 'test-pass');
    expect(verificationResult.connection, 'test-realm');
    expect(verificationResult.userMetadata['test'], 'test-123');
    expect(result, TestPlatform.signupResult);
  });

  test('signUp - set userMetadata to default value when omitted', () async {
    when(mockedPlatform.signup(any))
        .thenAnswer((final _) async => TestPlatform.signupResult);

    final result = await Auth0('test-domain', 'test-clientId').api.signup(
          email: 'test-email',
          password: 'test-pass',
          connection: 'test-realm',
        );

    final verificationResult =
        verify(mockedPlatform.signup(captureAny)).captured.single;
    // ignore: inference_failure_on_collection_literal
    expect(verificationResult.userMetadata, {});
    expect(result, TestPlatform.signupResult);
  });
}
