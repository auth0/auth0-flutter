import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('auth0.com/auth0_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel
        .setMockMethodCallHandler((final MethodCall methodCall) async => '42');
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Auth0Flutter.platformVersion, '42');
  });
}
