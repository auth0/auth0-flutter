import 'package:appium_driver/async_io.dart';

Future<AppiumWebElement> waitForElement(
    final AppiumWebDriver driver, final AppiumBy by,
    {final int timeout = 2500}) async {
  const delayDuration = Duration(milliseconds: 500);
  final maxTries = timeout / delayDuration.inMilliseconds;

  var currentTry = 0;

  while (currentTry < maxTries) {
    await Future<dynamic>.delayed(delayDuration);
    currentTry++; // 2

    try {
      return await driver.findElement(by);
    } on NoSuchElementException {
      if (currentTry == maxTries) {
        rethrow;
      }
    }
  }

  throw Exception("Should't get here");
}
