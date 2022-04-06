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

  Future<dynamic>? methodCallHandler(final MethodCall? methodCall) async {
    if (methodCall?.method == 'auth#login') {
      return loginResult;
    }
  }
}

@GenerateMocks([MethodCallHandler])
void main() {
  const MethodChannel channel =
      MethodChannel('auth0.com/auth0_flutter/auth');

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

    final result = await MethodChannelAuth0FlutterAuth().login(AuthLoginOptions(
        account: const Account('', ''),
        usernameOrEmail: '',
        password: '',
        connectionOrRealm: ''));

    expect(verify(mocked.methodCallHandler(captureAny)).captured.single.method,
        'auth#login');
    expect(result.accessToken, MethodCallHandler.loginResult['accessToken']);
  });
}
