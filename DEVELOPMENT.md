## Building

As a Flutter plugin can not be built as a standalone application, the only way to verify the compilation is to build the example application using `flutter build apk` or `flutter build ios` from inside `/auth0_flutter/example`.

## Running package tests

Run the unit tests for both packages using `flutter test` in **/auth0_flutter** and **/auth0_flutter_platform_interface** respectively.

## Running the example app

The example app can be run by executing `flutter run` in **/auth0_flutter/example**.

## Android Integration tests

UIAutomator interacts with device emulators, ensure an emulator for Android or iOS is running and accessible before running the tests.

### Environment Variables

The above tests rely on a couple of environment variables that can be defined in **/auth0_flutter/example/.env**:

- `AUTH0_DOMAIN`: Auth0 Domain
- `AUTH0_CLIENT_ID`: Auth0 Client Id
- `USER_EMAIL`: Email to log into the configured Auth0 Domain and Client Id
- `USER_PASSWORD`: Password to log into the configured Auth0 Domain and Client Id

### Running the tests

With the environment variables defined, we can execute the integration tests using the terminal from **/auth0_flutter/example/android**:

```
./gradlew connectedDebugAndroidTest
```

