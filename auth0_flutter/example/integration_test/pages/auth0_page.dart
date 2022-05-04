import 'package:appium_driver/async_io.dart';

import '../utils/wait_for.dart';

class Auth0Page {
  AppiumWebDriver driver;

  Auth0Page({required this.driver});

  Future<void> enterCredentialsAndSubmit(
      final String email, final String password) async {
    await waitForBrowser();

    final emailInput = await getEmailInput();
    final passwordInput = await getPasswordInput();

    await emailInput.sendKeys(email);
    await passwordInput.sendKeys(password);

    final loginButton = await getLoginButton();

    await loginButton.click();
  }

  Future<void> waitForBrowser() async {
    await waitForElement(
        driver, const AppiumBy.className('android.webkit.WebView'));
  }

  Future<AppiumWebElement> getEmailInput() {
    return driver
        .findElements(const AppiumBy.className('android.widget.EditText'))
        .elementAt(0);
  }

  Future<AppiumWebElement> getPasswordInput() {
    return driver
        .findElements(const AppiumBy.className('android.widget.EditText'))
        .elementAt(1);
  }

  Future<AppiumWebElement> getLoginButton() {
    return driver
        .findElements(const AppiumBy.className('android.widget.Button'))
        .elementAt(1);
  }
}
