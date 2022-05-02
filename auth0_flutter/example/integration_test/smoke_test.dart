import 'package:appium_driver/async_io.dart';
import 'package:dotenv/dotenv.dart' as dart_dot_env;
import 'package:test/test.dart';

import 'capabilities/capabilities.dart';
import 'pages/auth0_page.dart';
import 'pages/example_page.dart';
import 'pages/system_page.dart';

dart_dot_env.DotEnv env = dart_dot_env.DotEnv(includePlatformEnvironment: true)
  ..load();

String email = env['AUTH0_TEST_USERNAME'] ?? '';
String password = env['AUTH0_TEST_PASSWORD'] ?? '';
String appiumUrl = env['AUTH0_TEST_APPIUM_URL'] ?? '';

void main() {
  late AppiumWebDriver driver;
  late SystemPage systemPage;
  late ExamplePage examplePage;
  late Auth0Page auth0Page;

  setUpAll(() async {
    driver = await createDriver(
        uri: Uri.parse(appiumUrl), desired: Capabilities.android);
    examplePage = ExamplePage(driver: driver);
    auth0Page = Auth0Page(driver: driver);
    systemPage = SystemPage(driver: driver);
  });

  tearDownAll(() async {
    await driver.quit();
  });

  test('correctly handles the login and logout flow', () async {
    // Ensure we are using the native context
    await systemPage.useNativeContext();

    // Start the login process by clicking the `Login` button,
    // which will redirect to Auth0.
    await examplePage.startLogin();

    // Enter the user's credentials in Auth0
    await auth0Page.enterCredentialsAndSubmit(email, password);

    // Start the logout process by clicking the `Logout` button,
    // which will redirect to Auth0 and redirect back.
    await examplePage.startLogout();

    await Future<void>.delayed(const Duration(seconds: 2));

    // Expect the logout button to be hidden
    await expectLater(() => examplePage.getLogoutButton(),
        throwsA(isA<NoSuchElementException>()));
  });
}
