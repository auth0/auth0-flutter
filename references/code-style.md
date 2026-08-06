# Code Style

Read this when writing new Dart code. See [CLAUDE.md](../CLAUDE.md) for the CI-enforced rules that always apply.

## Patterns used in this project

- **Options objects** — every API call takes a typed `*Options` class with a `toMap()` method that serializes to the map sent over `MethodChannel` (e.g. `AuthLoginOptions`, `GetCredentialsOptions`, `MyAccountEnrollPhoneOptions`). New API surface should follow this shape rather than passing positional/named primitives directly to platform methods.
- **Request wrapping** — every platform call is wrapped in a `BaseRequest` subtype (`ApiRequest`, `CredentialsManagerRequest`, `WebAuthRequest` in `auth0_flutter_platform_interface/lib/src/request/request.dart`) that always attaches `Account` and `UserAgent` before serializing.
- **MethodChannel dispatch** — each feature area has a `method_channel_auth0_flutter_*.dart` implementation (auth, MFA, my-account, web-auth, credentials-manager) that extends the corresponding `*Platform` abstract class from `plugin_platform_interface`.
- **Web vs. native split** — `auth0_flutter/lib/src/web/` contains a `_real.dart` implementation (using `dart:js_interop`) and a `_stub.dart` implementation, selected via conditional imports, so non-web platforms compile without pulling in JS interop.

## Good example (options class with `toMap()`, from `credentials_manager_configuration.dart`)

```dart
class AndroidCredentialsConfiguration {
  String sharedPreferenceName;

  AndroidCredentialsConfiguration(this.sharedPreferenceName);

  Map<String, dynamic> toMap() => {
        'sharedPreferencesName': sharedPreferenceName,
      }..removeWhere((final key, final value) => value == null);
}
```

## Bad example (violates `prefer_final_parameters`, `type_annotate_public_apis`, `prefer_single_quotes`)

```dart
class AndroidCredentialsConfiguration {
  var sharedPreferenceName;

  AndroidCredentialsConfiguration(this.sharedPreferenceName);

  toMap() => {
    "sharedPreferencesName": sharedPreferenceName,
  };
}
```
