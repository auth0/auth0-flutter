import 'dart:io';

import 'package:appium_driver/async_io.dart';
import 'package:auth0_flutter_example/main.dart' as app;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<Finder> waitFor(final WidgetTester tester, final Finder finder,
    {final Duration timeout = const Duration(seconds: 10)}) async {
  final maxAmountOfTries = timeout.inSeconds / 0.5;
  var currentTry = 1;

  await tester.pumpAndSettle();

  while (finder.evaluate().isEmpty && currentTry < maxAmountOfTries) {
    await Future.delayed(const Duration(milliseconds: 500), () {});
    await tester.pumpAndSettle();
    currentTry += 1;
  }

  if (currentTry == maxAmountOfTries) {
    throw Exception('Couldnt find element after $currentTry tries');
  }

  return Future.value(finder);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /*group('Auth API', () {
    testWidgets('should show the ID Token after logging in',
        (final WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final emailInput = find.byType(TextField).first;
      final passwordInput = find.byType(TextField).last;

      await tester.enterText(emailInput, 'frederik.prijck@gmail.com');
      await tester.enterText(passwordInput, 'J2kkhtxd!');

      expect(find.text('API Login'), findsOneWidget);

      final loginButton = find.text('API Login');
      await tester.tap(loginButton);

      await waitFor(tester, find.textContaining('ID Token:'));

      expect(find.textContaining('ID Token:'), findsOneWidget);
    });
  });*/

  group('Web Auth API', () {
    late AppiumWebDriver driver;
    final localServer = Uri.parse('http://127.0.0.1:4723/wd/hub/');

    final androidDesiredCapabilitiesApp = {
      'platformName': 'Android',
      'app': File('build/app/outputs/flutter-apk/app-debug.apk').absolute.path,
      'deviceName': 'Android',
      'automationName': 'UiAutomator2',
      'appPackage': 'com.auth0.auth0_flutter_example',
      'appActivity': 'com.auth0.auth0_flutter_example.MainActivity',
      'unicodeKeyboard': true,
      'resetKeyboard': true,
      'disableWindowAnimation': true,
      'autoGrantPermissions': true,
      'language': 'en',
      'locale': 'US',
    };

    final iOSDesiredCapabilitiesApp = {
      'platformName': 'iOS',
      'platformVersion': '14.4',
      'app': File('build/ios/iphoneos/Runner.app').absolute.path,
      'deviceName': 'iPhone 12', // Runs tests in parallel per file by default
      'automationName': 'xcuitest',
      'wdaLocalPort': 8100,
      'useJSONSource': true,
      'reduceMotion': true
    };

    setUpAll(() async {
      driver = await createDriver(
          uri: localServer, desired: iOSDesiredCapabilitiesApp);
      await driver.timeouts.setImplicitTimeout(const Duration(seconds: 5));
    });

    tearDownAll(() async {
      // await driver.quit();
    });

    test('device lock', () async {
      expect(await driver.device.isLocked(), false);

      await driver.device.lock();
      expect(await driver.device.isLocked(), true);

      await driver.device.unlock();
      expect(await driver.device.isLocked(), false);

      await driver.device.lock(seconds: const Duration(seconds: 2));
      // wait 2 sec
      expect(await driver.device.isLocked(), false);

      var time = await driver.device.getSystemTime();
      expect(DateTime.parse(time) is DateTime, true); // Can parse without error
    });
    /*testWidgets('should show the ID Token after logging in',
        (final WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Web Auth Login'), findsOneWidget);

      final loginButton = find.text('Web Auth Login');
      await tester.tap(loginButton);

      await Future.delayed(const Duration(milliseconds: 5000), () {});
      await simulateKeyDownEvent(LogicalKeyboardKey.keyF,
          physicalKey: PhysicalKeyboardKey.keyF);
      await simulateKeyDownEvent(LogicalKeyboardKey.tab);
      await simulateKeyDownEvent(LogicalKeyboardKey.keyS);
      await simulateKeyDownEvent(LogicalKeyboardKey.tab);
      await simulateKeyDownEvent(LogicalKeyboardKey.enter);

      await waitFor(tester, find.textContaining('ID Token:'));

      expect(find.textContaining('ID Token:'), findsOneWidget);
    });*/
  });
}
