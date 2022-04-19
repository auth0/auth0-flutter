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

  test('login', () async {
    when(mocked.methodCallHandler(any))
        .thenAnswer((final _) async => MethodCallHandler.loginResult);

    final result = await MethodChannelAuth0FlutterWebAuth().login(
        WebAuthLoginInput(
            account: const Account('', ''),
            telemetry: Telemetry(name: '', version: ''),
            scopes: {}));

    expect(verify(mocked.methodCallHandler(captureAny)).captured.single.method,
        'webAuth#login');
    expect(result.accessToken, MethodCallHandler.loginResult['accessToken']);
  });
  test('logout', () async {
    when(mocked.methodCallHandler(any)).thenAnswer((final _) async => null);

    await MethodChannelAuth0FlutterWebAuth().logout(WebAuthLogoutInput(
        account: const Account('', ''),
        telemetry: Telemetry(name: '', version: '')));

    expect(verify(mocked.methodCallHandler(captureAny)).captured.single.method,
        'webAuth#logout');
  });
}
