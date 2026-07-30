# Testing Conventions

Read this when writing or modifying tests. See [CLAUDE.md](../CLAUDE.md) for the always-loaded safe command.

## Frameworks by layer

| Layer | Framework | Location |
|-------|-----------|----------|
| Dart (`auth0_flutter`) | `flutter_test` + `mockito` | `auth0_flutter/test/` |
| Dart (`auth0_flutter_platform_interface`) | `flutter_test` + `mockito` | `auth0_flutter_platform_interface/test/` |
| Android native | JUnit + Robolectric/Mockito-Kotlin | `auth0_flutter/android/src/test/kotlin/` |
| iOS/macOS native | XCTest | `auth0_flutter/example/ios/Tests/` (macOS's Runner target references the same directory) |
| Windows native | Custom C++ test binary (CMake target) | `auth0_flutter/windows/test/` |

## Mocking

- Mockito with `@GenerateMocks([...])` annotations; generated `*.mocks.dart` files sit next to the test file that declares the annotation (e.g. `method_channel_auth0_flutter_auth_test.mocks.dart`). Regenerate with `dart run build_runner build --delete-conflicting-outputs` after adding/changing a `@GenerateMocks` list — never hand-edit `*.mocks.dart`.
- Platform-channel tests mock `MethodChannel` calls directly (see `method_channel_auth0_flutter_auth_test.dart`), asserting on the map payload sent to the native side and stubbing the map returned from it.
- Test data is defined as `static const Map<dynamic, dynamic>` fixtures at the top of the test file (e.g. `MethodCallHandler.loginResult`) and reused via spread (`...loginResultRequired`) across related cases.

## Web-tagged tests

`auth0_flutter` tests that exercise `dart:js_interop` / web-only code are tagged `browser` (`@Tags(['browser'])` or inline tag) and require Chrome:

```bash
flutter test --tags browser --platform chrome
```

All other tests run with `flutter test --exclude-tags browser --coverage` and need no browser.

## Native / integration tier (Ask First — see Boundaries in CLAUDE.md)

- `test-ios-unit`, `test-macos-unit`, `test-android-unit` in `.github/workflows/main.yml` build the example app and run native tests against a real Auth0 tenant (`vars.AUTH0_DOMAIN`, `vars.AUTH0_CLIENT_ID`).
- Android integration tests (`./gradlew connectedDebugAndroidTest`, per `DEVELOPMENT.md`) need a running emulator plus `AUTH0_DOMAIN`, `AUTH0_CLIENT_ID`, `USER_EMAIL`, `USER_PASSWORD` in `auth0_flutter/example/.env`.
- Appium-based Android/iOS smoke tests (`appium-test/`) exist but are commented out in CI (`main.yml`) pending a fix — do not re-enable without checking with the maintainer first.

## Coverage

`flutter test --coverage` produces `coverage/lcov.info` (Dart); native platforms convert their own tool's output (JaCoCo/Kover XML, xcresult→Cobertura, OpenCppCoverage HTML) and all five reports upload to Codecov as separate flags (`auth0_flutter`, `auth0_flutter_platform_interface`, `auth0_flutter_ios`, `auth0_flutter_android`, `auth0_flutter_windows`). Codecov gates: 50% patch threshold, 2% project-drop threshold (`codecov.yml`).
