import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('auth0.com/auth0_flutter/web_auth');

  TestWidgetsFlutterBinding.ensureInitialized();

  const Map<dynamic, dynamic> loginResult = {
    'accessToken': 'accessToken',
    'idToken': 'idToken',
    'refreshToken': 'refreshToken',
    'expiresIn': 10,
    'scopes': ['a'],
    'userProfile': {'name': 'John Doe'}
  };
  setUp(() {
    channel.setMockMethodCallHandler(
        (final MethodCall methodCall) async => loginResult);
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('login', () async {
    final result = await Auth0('test', 'test').webAuthentication.login();
    expect(result.accessToken, loginResult['accessToken']);
  });
}
