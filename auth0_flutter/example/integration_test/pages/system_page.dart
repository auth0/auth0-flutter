import 'package:appium_driver/async_io.dart';

class SystemPage {
  AppiumWebDriver driver;
  SystemPage({required this.driver});

  Future<void> useNativeContext() async {
    await driver.contexts.setContext('NATIVE_APP');
  }
}
