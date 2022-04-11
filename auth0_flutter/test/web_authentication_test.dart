import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'web_authentication_test.mocks.dart';

class TestPlatform extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        Auth0FlutterWebAuthPlatform {
  static LoginResult loginResult = LoginResult.fromMap({
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': DateTime.now().toIso8601String(),
    'scopes': ['a', 'b'],
    'userProfile': {'name': 'John Doe'}
  });
}

@GenerateMocks([TestPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockedPlatform = MockTestPlatform();

  setUp(() {
    Auth0FlutterWebAuthPlatform.instance = mockedPlatform;
    reset(mockedPlatform);
  });

  test('login', () async {
    when(mockedPlatform.login(any))
        .thenAnswer((final _) async => TestPlatform.loginResult);

    final result = await Auth0('test-domain', 'test-clientId')
        .webAuthentication
        .login(
            audience: 'test-audience',
            scopes: {'a', 'b'},
            invitationUrl: 'invitation_url',
            organizationId: 'org_123',
            redirectUri: 'redirect_uri',
            useEphemeralSession: true);

    final verificationResult = verify(mockedPlatform.login(captureAny))
        .captured
        .single as WebAuthLoginInput;
    expect(verificationResult.account.domain, 'test-domain');
    expect(verificationResult.account.clientId, 'test-clientId');
    expect(verificationResult.audience, 'test-audience');
    expect(verificationResult.scopes, {'a', 'b'});
    expect(verificationResult.invitationUrl, 'invitation_url');
    expect(verificationResult.organizationId, 'org_123');
    expect(verificationResult.redirectUri, 'redirect_uri');
    expect(verificationResult.useEphemeralSession, true);
    expect(result, TestPlatform.loginResult);
  });

  test('login - does not use EphemeralSession by default', () async {
    when(mockedPlatform.login(any))
        .thenAnswer((final _) async => TestPlatform.loginResult);

    final result = await Auth0('test-domain', 'test-clientId')
        .webAuthentication
        .login(audience: 'test-audience', scopes: {'a', 'b'});

    final verificationResult = verify(mockedPlatform.login(captureAny))
        .captured
        .single as WebAuthLoginInput;
    expect(verificationResult.useEphemeralSession, false);
    expect(result, TestPlatform.loginResult);
  });

  test('logout', () async {
    when(mockedPlatform.logout(any)).thenAnswer((final _) async => {});

    await Auth0('test-domain', 'test-clientId')
        .webAuthentication
        .logout(returnTo: 'abc');

    final verificationResult =
        verify(mockedPlatform.logout(captureAny)).captured.single;
    expect(verificationResult.account.domain, 'test-domain');
    expect(verificationResult.account.clientId, 'test-clientId');
    expect(verificationResult.returnTo, 'abc');
  });
}
