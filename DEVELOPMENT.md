## Building

As a Flutter plugin can not be built as a standalone application, the only way to verify the compilation is to build the example application using `flutter build apk` or `flutter build ios` from inside `/auth0_flutter/example`.

## Configuring git hooks

The `.githooks` folder contains git hooks specific to this repository. To make sure these get called, after cloning run the following **from the repository root**:

```sh
git config core.hooksPath .githooks
```

## iOS/macOS dependency versions

The native Auth0 dependencies (`Auth0.swift`, `JWTDecode.swift`, `SimpleKeychain`) are declared in two places for the iOS/macOS SDK:

- **`auth0_flutter/darwin/auth0_flutter/Package.swift`** — the Swift Package Manager manifest. This is the **single source of truth**, and the only file [Dependabot](.github/dependabot.yml) updates (via the `swift` ecosystem). CocoaPods has no Dependabot support, so bumps land here.
- **The three CocoaPods podspecs** (`auth0_flutter/ios`, `auth0_flutter/macos`, `auth0_flutter/darwin`) — consumed by apps that use CocoaPods rather than SPM. These must be kept in sync with `Package.swift` manually.

To propagate a version change from `Package.swift` into the podspecs, run **from the repository root**:

```sh
scripts/sync-darwin-deps.sh
```

The [`Darwin dependencies` workflow](.github/workflows/check-darwin-deps.yml) enforces this on every PR: it runs the script and fails if the podspecs are out of sync, so a Dependabot bump of `Auth0.swift` will show a red check until someone runs the script and commits the result.

> This whole mechanism only exists because the podspecs duplicate the SPM version pin. Once the CocoaPods podspecs are no longer needed, the script and the workflow can both be removed.

## Running package tests

Run the unit tests for both packages using `flutter test` in **/auth0_flutter** and **/auth0_flutter_platform_interface** respectively.

## Running the example app

The example app can be run by executing `flutter run` in **/auth0_flutter/example**.

## Android Integration tests

UIAutomator interacts with device emulators, ensure an emulator for Android is running and accessible before running the tests.

### Environment Variables

The above tests rely on a couple of environment variables that can be defined in **/auth0_flutter/example/.env**:

- `AUTH0_DOMAIN`: Auth0 Domain
- `AUTH0_CLIENT_ID`: Auth0 Client ID
- `USER_EMAIL`: Email to log into the configured Auth0 Domain and Client ID
- `USER_PASSWORD`: Password to log into the configured Auth0 Domain and Client ID

### Running the tests

With the environment variables defined, we can execute the integration tests using the terminal from **/auth0_flutter/example/android**:

```
./gradlew connectedDebugAndroidTest
```
