import 'package:appium_driver/async_io.dart';

import '../utils/wait_for.dart';

class Auth0Page {
  static const webViewClass = 'android.webkit.WebView';
  static const inputClass = 'android.widget.EditText';
  static const buttonClass = 'android.widget.Button';

  AppiumWebDriver driver;

  Auth0Page({required this.driver});

  Future<void> enterCredentialsAndSubmit(
      final String email, final String password) async {
    await waitForBrowser();
    await waitForInputs();

    final emailInput = await getEmailInput();
    final passwordInput = await getPasswordInput();

    await emailInput.sendKeys(email);
    await passwordInput.sendKeys(password);

    final loginButton = await getLoginButton();

    await loginButton.click();
  }

  Future<void> waitForBrowser() async {
    await waitForElement(
        driver, const AppiumBy.className(webViewClass));
  }

  Future<void> waitForInputs() async {
    await waitForElement(driver, const AppiumBy.className(inputClass));
  }

  Future<AppiumWebElement> getEmailInput() {
    return driver
        .findElements(const AppiumBy.className(inputClass))
        .elementAt(0);
  }

  Future<AppiumWebElement> getPasswordInput() {
    return driver
        .findElements(const AppiumBy.className(inputClass))
        .elementAt(1);
  }

  Future<AppiumWebElement> getLoginButton() {
    return driver
        .findElements(const AppiumBy.className(buttonClass)).last;
  }
}
