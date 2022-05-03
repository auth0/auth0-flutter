## Building

As a Flutter plugin can not be built as a standalone application, the only way to verify the compilation is to build the example application using `flutter build apk` or `flutter build ios` from inside `/auth0_flutter/example`.

## Running package tests

Run the unit tests for both packages using `flutter test` in **/auth0_flutter** and **/auth0_flutter_platform_interface** respectively.

## Running the example app

The example app can be run by executing `flutter run` in **/auth0_flutter/example**.

## Integration tests

### Appium

> ⚠️ If you haven't installed Node yet, be sure to install the latest LTS version from [https://nodejs.org/en/download/](https://nodejs.org/en/download/).

The integration tests are configured to use [Appium](https://appium.io/), make sure it's is installed using npm:

```
npm i -g appium
```

As Appium needs to be able to communicate with the flutter example application, install the flutter driver using npm:

```
npm i -g appium-flutter-driver
```

Once the above dependencies are installed, verify the Appium installation by using [appium-doctor](https://github.com/appium/appium-doctor):

```
npx appium-doctor
```

If there appears to be some issues with any of the **necessary** dependencies, fix those and run `npx appium-doctor` again.
Once `npx appium-doctor` reports a succesful installation, appium can be started using the terminal:

```
appium
```

> ⚠️ Appium interacts with device emulators, ensure an emulator for Android or iOS is running and accessible from the Appium server before running the tests.

### Environment Variables

The above tests rely on a couple of environment variables that can be defined in **/auth0_flutter/example/.env**:

- `AUTH0_DOMAIN`: Auth0 Domain
- `AUTH0_CLIENT_ID`: Auth0 Client Id
- `USER_EMAIL`: Email to log into the configured Auth0 Domain and Client Id
- `USER_PASSWORD`: Password to log into the configured Auth0 Domain and Client Id
- `APPIUM_URL`: The URL to the Appium (`/wd/hub`) Endpoint.

When running Appium locally, the url for Appium typically is `http://127.0.0.1:4723/wd/hub/`.

### Running the tests

With Appium running succesfully, and the environment variables defined, we can execute the integration tests using the terminal from **/auth0_flutter/example**:

```
dart integration_test/smoke_test.dart
```

