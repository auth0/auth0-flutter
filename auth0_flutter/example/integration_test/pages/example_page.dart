import 'package:appium_driver/async_io.dart';

import '../utils/wait_for.dart';

class ExamplePage {
  AppiumWebDriver driver;

  ExamplePage({required this.driver});

  Future<void> startLogin() async {
    final element = await getLoginButton();
    await element.click();
  }

  Future<void> startLogout() async {
    final element = await getLogoutButton();
    await element.click();
  }

  Future<AppiumWebElement> getLoginButton() {
    return waitForElement(driver, const AppiumBy.accessibilityId('Web Auth Login'));
  }

  Future<AppiumWebElement> getLogoutButton() {
    return waitForElement(driver, const AppiumBy.accessibilityId('Web Auth Logout'));
  }
}
