import 'package:appium_driver/async_io.dart';
import 'package:test/test.dart';

import 'capabilities/capabilities.dart';

String email = '';
String password = '';

class ExamplePage {
  AppiumWebDriver driver;

  ExamplePage({required this.driver});

  Future<void> startLogin() async {
    final element = await getLoginButton();
    await element.click();
    await Future<dynamic>.delayed(const Duration(seconds: 2));
  }

  Future<AppiumWebElement> getLoginButton() {
    return driver
        .findElement(const AppiumBy.accessibilityId('Web Auth Login'));
  }

  Future<AppiumWebElement> getLogoutButtom() {
    return driver
        .findElement(const AppiumBy.accessibilityId('Web Auth Logout'));
  }
}

class Auth0Page {

  AppiumWebDriver driver;

  Auth0Page({required this.driver});

  Future<void> enterCredentialsAndSubmit() async {
    final emailInput = await driver
        .findElements(const AppiumBy.className('android.widget.EditText'))
        .elementAt(0);
    final passwordInput = await driver
        .findElements(const AppiumBy.className('android.widget.EditText'))
        .elementAt(1);

    await emailInput.sendKeys(email);
    await passwordInput.sendKeys(password);

    await Future<dynamic>.delayed(const Duration(seconds: 2));

    final loginButton = await driver
        .findElements(const AppiumBy.className('android.widget.Button'))
        .elementAt(1);

    await loginButton.click();

  }
}

class System {
  AppiumWebDriver driver;
  System({required this.driver});

  Future<void> useNativeContext() async {
    await driver.contexts.setContext('NATIVE_APP');
  }

  Future<void> activateAUT() async {
    await driver.app.activate('com.auth0.auth0_flutter_example');
    await Future<dynamic>.delayed(const Duration(seconds: 15));
  }
}

void main() {
  late AppiumWebDriver driver;
  late System system;
  late ExamplePage examplePage;
  late Auth0Page auth0Page;
  final localServer = Uri.parse('http://127.0.0.1:4723/wd/hub/');

  setUpAll(() async {
    driver =
        await createDriver(uri: localServer, desired: Capabilities.android);
    examplePage = ExamplePage(driver: driver);
    auth0Page = Auth0Page(driver: driver);
    system = System(driver: driver);
  });

  tearDownAll(() async {
    await driver.quit();
  });

  test('connect to server', () async {
    await system.useNativeContext();
    await examplePage.startLogin();

    // iOS only
    // driver.switchTo.alert.accept();

    await auth0Page.enterCredentialsAndSubmit();

    await system.activateAUT();

    final logoutButton = await driver
        .findElement(const AppiumBy.accessibilityId('Web Auth Logout'));
    logoutButton.click();

    // expectLater(actual, throwsA(isA<NoSuchElementException>()));
  });
}
