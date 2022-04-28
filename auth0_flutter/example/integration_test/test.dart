import 'dart:io';

import 'package:appium_driver/async_io.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  late AppiumWebDriver driver;
  final localServer = Uri.parse('http://127.0.0.1:4723/wd/hub/');

  final androidDesiredCapabilitiesApp = {
    'platformName': 'Android',
    'app': File('build/app/outputs/flutter-apk/app-debug.apk').absolute.path,
    //'deviceName': 'emulator-5554',
    'deviceName': 'emulator-5554',
    'automationName': 'Flutter',
    //'appPackage': 'com.auth0.auth0_flutter_example',
    //'appActivity': 'com.auth0.auth0_flutter_example.MainActivity',
    //'unicodeKeyboard': true,
    //'resetKeyboard': true,
    //'disableWindowAnimation': true,
    //'autoGrantPermissions': true,
    //'language': 'en',
    //'locale': 'US',
  };

  final iOSDesiredCapabilitiesApp = {
    'platformName': 'ios',
    'platformVersion': '15.4',
    'deviceName': 'iPhone 12 Pro',
    //'browserName': 'Safari',
    //'automationName': 'XCUITest',
    'automationName': 'Flutter',
    'reduceMotion': true,
    'app': File('build/ios/iphonesimulator/Runner.app').absolute.path,
  };

  setUpAll(() async {
    driver = await createDriver(
        uri: localServer, desired: androidDesiredCapabilitiesApp);
  });

  tearDownAll(() async {
    await driver.quit();
  });

  test('connect to server', () async {
    //expect(await driver.title, 'Appium/welcome');

    //await driver.app.install(File('build/ios/iphonesimulator/Runner.app').absolute.path);
    //await driver.app.activate('com.auth0.auth0FlutterExample');
    //await driver.app.launch();

    // TODO: Avoid delay
    await Future<dynamic>.delayed(const Duration(seconds: 2));


    List<String> contextNames = await driver.contexts.getAvailableContexts();
    print(contextNames);
    //driver.contexts.setContext(contextNames[1]);

    //expect(await driver.execute('flutter:checkHealth', []), 'ok');
    //AppiumBy.custom(custom)
    final _element = await driver
        .findElement(const AppiumBy('css selector', 'webAuthLoginBtn'));
    final element = await driver
        .findElement(const AppiumBy.accessibilityId('webAuthLoginBtn'));
    element.click();



    //await Future<dynamic>.delayed(const Duration(seconds: 5));

    await Future<dynamic>.delayed(const Duration(seconds: 2));
    //driver.switchTo.alert.accept();


    //await driver.app.activate('com.auth0.auth0FlutterExample');

    await Future<dynamic>.delayed(const Duration(seconds: 2));

    //driver.contexts.setContext(contextNames[1]);
    final element2 = await driver
        .findElement(const AppiumBy.tagName('input'));

        element2.sendKeys('test@test.com');

    await Future<dynamic>.delayed(const Duration(seconds: 2));

    //expect(buttons.id, 2);
    //expect(await driver.execute('flutter:checkHealth', []), 'ok');
    driver.contexts.setContext(contextNames[0]);
    /*final element3 = await driver
        .findElement(const AppiumBy.accessibilityId('webAuthLoginBtn'));
        expect(element3, null);*/
  });

  /*test('connect to existing session', () async {
    var sessionId = driver.id;

    AppiumWebDriver newDriver = await fromExistingSession(sessionId);
    expect(await newDriver.title, 'Appium/welcome');
    expect(newDriver.id, sessionId);
  });

  test('find by appium element', () async {
    const title = 'Appium/welcome';
    try {
      await driver.findElement(const AppiumBy.accessibilityId(title));
      throw 'expected Unsupported locator strategy: accessibility id error';
    } on UnknownException catch (e) {
      expect(
          e.message!.contains('Unsupported locator strategy: accessibility id'),
          true);
    }
  });*/
}
