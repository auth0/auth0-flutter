import 'package:appium_driver/async_io.dart';

class Auth0Page {
  AppiumWebDriver driver;

  Auth0Page({required this.driver});

  Future<void> enterCredentialsAndSubmit(final String email, final String password) async {
    await Future<dynamic>.delayed(const Duration(seconds: 5));
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

    await Future<dynamic>.delayed(const Duration(seconds: 5));
  }
}
