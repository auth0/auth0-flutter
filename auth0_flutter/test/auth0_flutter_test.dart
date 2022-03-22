import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('plugins.flutter.io/auth0_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Auth0Flutter.platformVersion, '42');
  });
}
