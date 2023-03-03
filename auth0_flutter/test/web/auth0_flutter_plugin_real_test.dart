@Tags(['browser'])

import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'auth0_flutter_plugin_real_test.mocks.dart';

class TestPlatform extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        Auth0FlutterWebPlatform {
  static Credentials loginResult = Credentials.fromMap({
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresAt': DateTime.now().toIso8601String(),
    'scopes': ['a', 'b'],
    'userProfile': {'sub': '123', 'name': 'John Doe'},
    'tokenType': 'Bearer'
  });
}

@GenerateMocks([TestPlatform])
void main() {
  final auth0 = Auth0Web('test-domain', 'test-client-id');
  final Auth0FlutterWebPlatform mockedPlatform = MockTestPlatform();

  setUp(() {
    Auth0FlutterWebPlatform.instance = mockedPlatform;
    reset(mockedPlatform);
  });

  test('onLoad', () async {
    when(mockedPlatform.credentials())
        .thenAnswer((final r) => Future.value(TestPlatform.loginResult));

    expect(await auth0.onLoad(), TestPlatform.loginResult);
  });
}
