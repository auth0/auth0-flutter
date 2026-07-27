# Command Reference

Full command list, extracted from `.github/workflows/main.yml`, `.github/workflows/publish-af.yml`/`publish-afpi.yml`, and `DEVELOPMENT.md`. See [CLAUDE.md](../CLAUDE.md) for the always-loaded quick set.

## Setup

```bash
# From the repo root, once per clone — makes the symlink pre-commit hook active
git config core.hooksPath .githooks

# auth0_flutter needs a .env before analyze/test (mobile/desktop code reads it)
cd auth0_flutter && cp example/.env.example example/.env   # bash/macOS/Linux
# Copy-Item example/.env.example example/.env              # PowerShell (Windows CI)
```

## Dart / Flutter (both packages)

```bash
# auth0_flutter
cd auth0_flutter
flutter pub get
flutter analyze --no-fatal-warnings --no-fatal-infos
flutter test --tags browser --platform chrome    # web-tagged tests need Chrome
flutter test --coverage --exclude-tags browser    # the rest, with coverage

# auth0_flutter_platform_interface
cd auth0_flutter_platform_interface
flutter pub get
flutter analyze
flutter test --coverage

# Format (either package)
dart format .

# Regenerate mocks/build_runner output after changing an @GenerateMocks annotation
dart run build_runner build --delete-conflicting-outputs
```

## Example app (manual verification — a Flutter plugin can't be built standalone)

```bash
cd auth0_flutter/example
flutter pub get
flutter run                      # any connected device/simulator
flutter build apk --split-per-abi
flutter build ios
flutter build macos --debug
flutter build windows --debug
```

## Native unit tests (CI — need toolchains/credentials not present in a plain dev shell)

```bash
# iOS/macOS (from .github/actions/unit-tests-darwin + setup-darwin)
# requires Xcode, pod install, and AUTH0_DOMAIN/AUTH0_CLIENT_ID vars
cd auth0_flutter/example/ios
xcodebuild test -scheme Runner -workspace Runner.xcworkspace \
  -destination 'platform=iOS Simulator,name=iPhone 17' -skip-testing:RunnerUITests

# Android (from .github/actions/setup-android)
cd auth0_flutter/example/android && ./gradlew koverXmlReportDebug

# Windows (native C++ client, no vendor SDK — built via CMake + vcpkg)
cd auth0_flutter/windows
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=<path-to-vcpkg>/scripts/buildsystems/vcpkg.cmake \
  -DAUTH0_FLUTTER_ENABLE_TESTS=ON -DCMAKE_BUILD_TYPE=Debug
cmake --build build --config Debug
```

## Android integration tests (require a running emulator + example/.env)

```bash
cd auth0_flutter/example/android
./gradlew connectedDebugAndroidTest
```

## Symlink check (CI: `check-symlinks.yml`)

```bash
# Run after editing anything under auth0_flutter/darwin/auth0_flutter/Sources/
scripts/generate-symlinks.sh
```

## Publish (CI only — `publish-af.yml` / `publish-afpi.yml`, triggered by `af-v*`/`afpi-v*` tags)

```bash
dart pub publish -f
```
